//
//  StoryOverview.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "StoryOverview.h"

#import "NSXMLNode+QuickerXPath.h"

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

@end

@implementation StoryOverview

+ (void)initialize
{
	baseURL = [NSURL URLWithString:@"http://www.fanfiction.net/"];
	genres = @[ @"General", @"Romance", @"Humor", @"Drama", @"Poetry", @"Adventure", @"Mystery", @"Horror", @"Parody", @"Angst", @"Supernatural", @"Suspense", @"Sci-Fi", @"Fantasy", @"Spiritual", @"Tragedy", @"Western", @"Crime", @"Family", @"Hurt", @"Comfort", @"Friendship" ];
}

- (id)initWithHTMLData:(NSData *)data error:(NSError * __autoreleasing *)error;
{
	if (!(self = [super init])) return nil;
	
	NSString *dataAsUTF8 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	NSXMLDocument *document = [[NSXMLDocument alloc] initWithXMLString:dataAsUTF8 options:NSXMLDocumentTidyHTML error:error];
	if (!document) return nil;
	
	// Data that can be easily gotten via XPath (at the moment)
	_title = [document firstTextForXPath:titleXPath error:error];
	_author = [document firstTextForXPath:authorNameXPath error:error];
	_authorURL = [document firstURLForXPath:authorURLXPath relativeToBase:baseURL error:error];
	_imageURL = [document firstURLForXPath:imageURLXPath relativeToBase:baseURL error:error];
	
	_summary = [document firstTextForXPath:summaryXPath error:error];
	
	_category = [document allTextForXPath:categoryXPath error:error];
	
	_categoryURL = [document firstURLForXPath:categoryURLXPath relativeToBase:baseURL error:error];
	
	// Things that require more involved parsing here.
	[self _parseTokens:[document firstTextForXPath:tokenListXPath error:error]];
	
	if (self.chapterCount == 0) _chapterCount = 1;
	if (self.updated == nil) _updated = self.published;
	if (self.genre == nil) _genre = @"Unspecified";
	if (self.characters == nil) _characters = @"Unspecified";
	
	return self;
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
			_rating = [token substringFromIndex:[@"Rated: " length]];
		
		else if ([key isEqual:@"Chapters"])
			_chapterCount = [[numberFormatter numberFromString:value] unsignedIntegerValue];
		
		else if ([key isEqual:@"Words"])
			_wordCount = [[numberFormatter numberFromString:value] unsignedIntegerValue];
		
		else if ([key isEqual:@"Reviews"])
			_reviewCount = [[numberFormatter numberFromString:value] unsignedIntegerValue];
		
		else if ([key isEqual:@"Favs"])
			_favoriteCount = [[numberFormatter numberFromString:value] unsignedIntegerValue];
		
		else if ([key isEqual:@"Follows"])
			_followerCount = [[numberFormatter numberFromString:value] unsignedIntegerValue];
		
		else if ([key isEqual:@"id"])
			_storyID = [[numberFormatter numberFromString:value] unsignedIntegerValue];
		
		else if ([key isEqual:@"Updated"])
			_updated = [dateFormatter dateFromString:value];
		
		else if ([key isEqual:@"Published"])
			_published = [dateFormatter dateFromString:value];
		
		else if ([key isEqual:@"Status"])
			_isComplete = [value isEqual:@"Complete"];
		
		else
		{
			if (self.genre == nil && [self _isTokenGenre:token])
			{
				_genre = token;
			}
			else
			{
				switch (uncategorizedState)
				{
					case Start:
						_language = token;
						uncategorizedState = Language;
						break;
					case Language:
						_characters = token;
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

+ (NSURL *)urlForStoryID:(NSUInteger)story chapter:(NSUInteger)chapter;
{
	return [NSURL URLWithString:[NSString stringWithFormat:chapterPattern, story, chapter] relativeToURL:baseURL];
}

- (NSURL *)urlForChapter:(NSUInteger)chapter
{
	return [[self class] urlForStoryID:self.storyID chapter:chapter];
}

+ (BOOL)URLisValidForStory:(NSURL *)storyURL errorDescription:(NSError * __autoreleasing *)error
{
	if (!storyURL)
	{
		if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
						  NSLocalizedDescriptionKey : NSLocalizedString(@"Not a valid URL", @"Cannot create NSURL from entered string"),
			  NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"Please enter a valid web address", @"Works better that way.")}];
		return NO;
	}
	
	NSString *host = storyURL.host;
	if (![host hasSuffix:@"fanfiction.net"])
	{
		if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
						  NSLocalizedDescriptionKey : NSLocalizedString(@"Not a FanFiction.net URL", @"Entered wrong host"),
			  NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"Only Fanfiction.net is supported at the moment.", @"Use correct host instead")}];
		return NO;
	}
	NSArray *pathComponents = storyURL.pathComponents;
	if (pathComponents.count < 3 || ![[pathComponents objectAtIndex:1] isEqual:@"s"])
	{
		if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
						  NSLocalizedDescriptionKey : NSLocalizedString(@"Not a story URL", @"Path doesn't start with /s/ or is too short"),
			  NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"This URL does not point to a story.", @"Give correct URL")}];
		return NO;
	}
	
	NSInteger storyID = [[pathComponents objectAtIndex:2] integerValue];
	if (storyID == 0)
	{
		if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
						  NSLocalizedDescriptionKey : NSLocalizedString(@"The URL has no story ID", @"Path[1] is not a number or 0."),
			  NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"This URL does not point to a story.", @"Give correct URL")}];
		return NO;
	}
	
	// Check whether we can find anything under the corresponding URL
	
	return YES;
}

+ (NSUInteger)storyIDFromURL:(NSURL *)storyURL
{
	NSArray *pathComponents = storyURL.pathComponents;
	if (pathComponents.count < 3 || ![[pathComponents objectAtIndex:1] isEqual:@"s"]) return 0;
	return (NSUInteger) [[pathComponents objectAtIndex:2] integerValue];
}

+ (BOOL)URLisValidAndExistsForStory:(NSURL *)storyURL errorDescription:(NSError * __autoreleasing *)error
{
	if (![self URLisValidForStory:storyURL errorDescription:error]) return NO;
	
	NSURL *firstChapterURL = [StoryOverview urlForStoryID:[self storyIDFromURL:storyURL] chapter:1];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:firstChapterURL];
	request.HTTPMethod = @"HEAD";
	
	NSHTTPURLResponse *response;
	NSError *loadError;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&loadError];
	if (!data || response.statusCode != 200)
	{
		if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
						  NSLocalizedDescriptionKey : NSLocalizedString(@"Could not find the story", @"Download returned no data or status code != 200"),
			  NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"The story at this location could not be retrieved. Maybe it was deleted, or the internet connection is down.", @"Give correct URL"),
						   NSUnderlyingErrorKey : loadError }];
		return NO;
	}
	return YES;
}

@end
