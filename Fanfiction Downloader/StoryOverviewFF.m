//
//  StoryOverviewFF.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 11.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "StoryOverviewFF.h"

#import "NSXMLNode+QuickerXPath.h"
#import "StoryID.h"
#import "StoryChapterFF.h"

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
static NSArray *genres;

@interface StoryOverviewFF ()

- (void)_parseTokens:(NSString *)tokenString;
- (NSArray *)_parseCharacters:(NSString *)characters;
- (BOOL)_isTokenGenre:(NSString *)mightDescribeGenre;

@end

@implementation StoryOverviewFF

+ (void)initialize
{
	baseURL = [NSURL URLWithString:@"http://www.fanfiction.net/"];
	genres = @[ @"General", @"Romance", @"Humor", @"Drama", @"Poetry", @"Adventure", @"Mystery", @"Horror", @"Parody", @"Angst", @"Supernatural", @"Suspense", @"Sci-Fi", @"Fantasy", @"Spiritual", @"Tragedy", @"Western", @"Crime", @"Family", @"Hurt", @"Comfort", @"Friendship" ];
}

- (BOOL)updateWithHTMLData:(NSData *)data error:(NSError *__autoreleasing *)error;
{
	// Create document. Turn into string by hand, since NSXMLDocument can't deal with HTML5-style encoding declarations.
	NSString *dataAsUTF8 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSXMLDocument *document = [[NSXMLDocument alloc] initWithXMLString:dataAsUTF8 options:NSXMLDocumentTidyHTML error:error];
	if (!document) return NO;
	
	// Data that can be easily gotten via XPath (at the moment)
	self.title = [document firstTextForXPath:titleXPath error:error];
	self.author = [document firstTextForXPath:authorNameXPath error:error];
	self.authorURL = [document firstURLForXPath:authorURLXPath relativeToBase:baseURL error:error];
	self.imageURL = [document firstURLForXPath:imageURLXPath relativeToBase:baseURL error:error];
	
	self.summary = [document firstTextForXPath:summaryXPath error:error];
	
	self.fandoms = @[ [document allTextForXPath:categoryXPath error:error] ];
		
	// Things that require more involved parsing here.
	[self _parseTokens:[document firstTextForXPath:tokenListXPath error:error]];
	
	// Optional tokens that still need some value filled in
	if (self.chapterCount == 0) self.chapterCount = 1UL;
	if (self.updated == nil) self.updated = self.published;
	
	return YES;
}

- (void)_parseTokens:(NSString *)tokenString
{
	if (!tokenString) return;
	
	/* Tokens come in two kinds: Those that have the form Key: Value, and those
	 * that are just random text. The first kind is split and processed based
	 * on the key. The second kind is language, genre or characters.. A simple
	 * state machine is used to separate them.
	 */
	
	NSArray *tokens = [tokenString componentsSeparatedByString:tokenSeparator];
	
	enum {
		Start,
		Language,
		Genre,
		Characters
	} lastUncategorizedState = Start;
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	numberFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
	numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat = @"MM-dd-yy";
	
	self.characters = @[];
	
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
		
		else if ([key isEqual:@"id"])
			; // Ignore
		
		
		else if ([key isEqual:@"Updated"])
			self.updated = [dateFormatter dateFromString:value];
		
		else if ([key isEqual:@"Published"])
			self.published = [dateFormatter dateFromString:value];
		
		else if ([key isEqual:@"Status"])
			self.isComplete = [value isEqual:@"Complete"];
		
		else
		{
			switch (lastUncategorizedState)
			{
				case Start:
					self.language = token;
					lastUncategorizedState = Language;
					break;
				case Language:
					if ([self _isTokenGenre:token])
					{
						self.genre = token;
						lastUncategorizedState = Genre;
					}
					else
					{
						self.characters = [self _parseCharacters:token];
						lastUncategorizedState = Characters;
					}
					break;
				case Genre:
					self.characters = [self _parseCharacters:token];
					lastUncategorizedState = Characters;
					break;
				case Characters:
				default:
					NSLog(@"Found more than three uncategorized tokens. Surplus: %@", token);
					break;
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

- (NSArray *)_parseCharacters:(NSString *)characters;
{
	NSRange ampersandLocation = [characters rangeOfString:@" & "];
	
	if (ampersandLocation.location == NSNotFound)
		return @[ characters ];
	
	NSString *char1 = [characters substringToIndex:ampersandLocation.location];
	NSString *char2 = [characters substringFromIndex:NSMaxRange(ampersandLocation)];
	return @[ char1, char2 ];
}

- (NSURL *)urlForChapter:(NSUInteger)chapter
{
	return [NSURL URLWithString:[NSString stringWithFormat:chapterPattern, self.storyID.siteSpecificID, chapter] relativeToURL:baseURL];
}

- (StoryChapter *)createChapterWithNumber:(NSUInteger)number;
{
	return [[StoryChapterFF alloc] initWithOverview:self chapterNumber:number];
}

@end
