//
//  StoryOverview.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "StoryOverview.h"

#import "NSXMLNode+QuickerXPath.h"
#import "StoryID.h"

static NSString *titleXPath = @"//table[@id='gui_table1i']//b[1]";
static NSString *authorNameXPath = @"//table[@id='gui_table1i']//a[1]";
static NSString *authorURLXPath = @"//table[@id='gui_table1i']//a[1]/attribute::href";
static NSString *summaryXPath = @"//table[@id='gui_table1i']//div[@style='margin-top:2px'][1]";
static NSString *categoryXPath = @"//div[@id='pre_story_links']/a[last()]/text()";
static NSString *categoryURLXPath = @"//div[@id='pre_story_links']/a[last()]/attribute::href";
static NSString *imageURLXPath = @"//table[@id='gui_table1i']//img[@class='cimage'][1]/attribute::src";

static NSString *tokenListXPath = @"//table[@id='gui_table1i']/tbody/tr[@class='alt2']/td/div[last()]";
static NSString *tokenSeparator = @" - ";


static NSString *chapterPattern = @"/s/%lu/%lu/";
static NSURL *baseURL = nil;
static NSArray *genres = nil;

@interface StoryOverview ()

- (void)_parseTokens:(NSString *)tokenString;
- (BOOL)_isTokenGenre:(NSString *)mightDescribeGenre;

@property (readwrite, copy, nonatomic) NSString *author;
@property (readwrite, copy, nonatomic) NSURL *authorURL;
@property (readwrite, assign, nonatomic) NSUInteger chapterCount;
@property (readwrite, copy, nonatomic) NSString *characters;
@property (readwrite, copy, nonatomic) NSString *category;
@property (readwrite, copy, nonatomic) NSURL *categoryURL;
@property (readwrite, assign, nonatomic) NSUInteger favoriteCount;
@property (readwrite, assign, nonatomic) NSUInteger followerCount;
@property (readwrite, copy, nonatomic) NSString *genre;
@property (readwrite, copy, nonatomic) NSURL *imageURL;
@property (readwrite, assign, nonatomic) BOOL isComplete;
@property (readwrite, copy, nonatomic) NSString *language;
@property (readwrite, copy, nonatomic) NSDate *published;
@property (readwrite, copy, nonatomic) NSString *rating;
@property (readwrite, assign, nonatomic) NSUInteger reviewCount;
@property (readwrite, copy, nonatomic) NSString *summary;
@property (readwrite, copy, nonatomic) NSString *title;
@property (readwrite, copy, nonatomic) NSDate *updated;

@property (readwrite, assign, nonatomic) NSUInteger wordCount;


@end

@implementation StoryOverview

+ (void)initialize
{
	baseURL = [NSURL URLWithString:@"http://www.fanfiction.net/"];
	genres = @[ @"General", @"Romance", @"Humor", @"Drama", @"Poetry", @"Adventure", @"Mystery", @"Horror", @"Parody", @"Angst", @"Supernatural", @"Suspense", @"Sci-Fi", @"Fantasy", @"Spiritual", @"Tragedy", @"Western", @"Crime", @"Family", @"Hurt", @"Comfort", @"Friendship" ];
}

- (id)initWithStoryID:(StoryID *)storyID;
{
	if (!(self = [super init])) return nil;
	
	_storyID = storyID;
	
	return self;
}

- (BOOL)updateWithHTMLData:(NSData *)data error:(NSError *__autoreleasing *)error;
{
	NSString *dataAsUTF8 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	NSXMLDocument *document = [[NSXMLDocument alloc] initWithXMLString:dataAsUTF8 options:NSXMLDocumentTidyHTML error:error];
	if (!document) return NO;
	
	// Data that can be easily gotten via XPath (at the moment)
	self.title = [document firstTextForXPath:titleXPath error:error];
	self.author = [document firstTextForXPath:authorNameXPath error:error];
	self.authorURL = [document firstURLForXPath:authorURLXPath relativeToBase:baseURL error:error];
	self.imageURL = [document firstURLForXPath:imageURLXPath relativeToBase:baseURL error:error];
	
	self.summary = [document firstTextForXPath:summaryXPath error:error];
	
	self.category = [document allTextForXPath:categoryXPath error:error];
	
	self.categoryURL = [document firstURLForXPath:categoryURLXPath relativeToBase:baseURL error:error];
	
	// Things that require more involved parsing here.
	[self _parseTokens:[document firstTextForXPath:tokenListXPath error:error]];
	
	if (self.chapterCount == 0) self.chapterCount = 1;
	if (self.updated == nil) self.updated = self.published;
	if (self.genre == nil) self.genre = @"Unspecified";
	if (self.characters == nil) self.characters = @"Unspecified";
	
	return YES;
}

- (void)_parseTokens:(NSString *)tokenString
{
	if (!tokenString) return;
	
	NSArray *tokens = [tokenString componentsSeparatedByString:tokenSeparator];
	
	enum {
		Start,
		Language,
		Characters
	} uncategorizedState = Start;
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	numberFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
	numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat = @"MM-dd-yy";
	
	for (NSString *token in tokens)
	{
		NSRange separatorRange = [token rangeOfString:@": "];
		
		NSString *key = [token substringToIndex: separatorRange.location != NSNotFound ? separatorRange.location : 0];
		NSString *value = [token substringFromIndex: separatorRange.location != NSNotFound ? NSMaxRange(separatorRange) : 0];
		
		if ([key isEqual:@"Rated"])
			self.rating = [token substringFromIndex:[@"Rated: " length]];
		
		else if ([key isEqual:@"Chapters"])
			self.chapterCount = [[numberFormatter numberFromString:value] unsignedIntegerValue];
		
		else if ([key isEqual:@"Words"])
			self.wordCount = [[numberFormatter numberFromString:value] unsignedIntegerValue];
		
		else if ([key isEqual:@"Reviews"])
			self.reviewCount = [[numberFormatter numberFromString:value] unsignedIntegerValue];
		
		else if ([key isEqual:@"Favs"])
			self.favoriteCount = [[numberFormatter numberFromString:value] unsignedIntegerValue];
		
		else if ([key isEqual:@"Follows"])
			self.followerCount = [[numberFormatter numberFromString:value] unsignedIntegerValue];
		
		else if ([key isEqual:@"Updated"])
			self.updated = [dateFormatter dateFromString:value];
		
		else if ([key isEqual:@"Published"])
			self.published = [dateFormatter dateFromString:value];
		
		else if ([key isEqual:@"Status"])
			self.isComplete = [value isEqual:@"Complete"];
		
		else
		{
			if (self.genre == nil && [self _isTokenGenre:token])
			{
				self.genre = token;
			}
			else
			{
				switch (uncategorizedState)
				{
					case Start:
						self.language = token;
						uncategorizedState = Language;
						break;
					case Language:
						self.characters = token;
						uncategorizedState = Characters;
						break;
					case Characters:
					default:
						NSLog(@"Found more than three uncategorized tokens. Surplus: %@", token);
						break;
				}
			}
		}
	}
}

- (BOOL)_isTokenGenre:(NSString *)mightDescribeGenre;
{
	for (NSString *part in [mightDescribeGenre componentsSeparatedByString:@"/"])
		if (![genres containsObject:part])
			return NO;
	
	return YES;
}

- (void)loadDataFromCache:(BOOL)useCacheWherePossible completionHandler:(void (^) (NSError *error))handler;
{
	NSURLCacheStoragePolicy policy = useCacheWherePossible ? NSURLRequestReturnCacheDataElseLoad : NSURLRequestReloadIgnoringLocalCacheData;
	
	NSURLRequest *request = [NSURLRequest requestWithURL:self.storyID.overviewURL cachePolicy:policy timeoutInterval:5.0];
	
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
		// Handle load error
		if (!data)
		{
			handler(error);
			return;
		};
		
		// Get overview
		NSError *parseError = nil;
		BOOL success = [self updateWithHTMLData:data error:&parseError];
		if (!success)
		{
			handler(parseError);
			return;
		}
		
		// Inform caller
		handler(nil);
	}];
}

- (NSURL *)urlForChapter:(NSUInteger)chapter
{
	return [NSURL URLWithString:[NSString stringWithFormat:chapterPattern, self.storyID.siteSpecificID, chapter] relativeToURL:baseURL];
}

@end
