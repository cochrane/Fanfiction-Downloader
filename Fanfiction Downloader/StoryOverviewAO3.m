//
//  StoryOverviewAO3.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 11.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "StoryOverviewAO3.h"

#import "NSArray+Map.h"
#import "NSXMLNode+QuickerXPath.h"
#import "StoryChapterAO3.h"
#import "StoryID.h"

static NSString *chapterURLXPath = @"//ol[@class='chapter index group']//a/attribute::href";

static NSString *authorXPath = @"//div[@id='workskin']/div[@class='preface group']/h3[@class='byline heading']/a[1]";
static NSString *authorURLXPath = @"//div[@id='workskin']/div[@class='preface group']/h3[@class='byline heading']/a[1]/attribute::href";
static NSString *charactersXPath = @"//dd[@class='character tags']/ul[1]/li/a";
static NSString *fandomsXPath = @"//dd[@class='fandom tags']/ul[1]/li/a";
static NSString *ratingXPath = @"//dd[@class='rating tags']/ul[1]/li/a[1]";
static NSString *summaryXPath = @"//div[@id='workskin']/div[@class='preface group']/div[@class='summary module']/blockquote[1]";
static NSString *relationshipsXPath = @"//dd[@class='relationship tags']/ul[1]/li/a";
static NSString *tagsXPath = @"//dd[@class='freeform tags']/ul[1]/li/a";
static NSString *titleXPath = @"//div[@id='workskin']/div[@class='preface group']/h2[1]";
static NSString *warningsXPath = @"//dd[@class='warning tags']/ul[1]/li/a";

static NSString *statsXPath = @"//dd[@class='stats']/dl[@class='stats']/(dd|dt)";

static NSURL *baseURL;

@interface StoryOverviewAO3 ()

@property (nonatomic) NSArray *chapterIDs;

@end

@implementation StoryOverviewAO3

+ (void)initialize
{
	baseURL = [NSURL URLWithString:@"http://archiveofourown.org/"];
}

- (BOOL)loadDataFromCache:(BOOL)useCacheWherePossible error:(NSError *__autoreleasing *)error;
{
	NSURLCacheStoragePolicy policy = useCacheWherePossible ? NSURLRequestReturnCacheDataElseLoad : NSURLRequestReloadIgnoringLocalCacheData;
	
	NSURLRequest *navigateRequest = [NSURLRequest requestWithURL:self.storyID.overviewURL cachePolicy:policy timeoutInterval:5.0];
	
	NSData *navigateResult = [NSURLConnection sendSynchronousRequest:navigateRequest returningResponse:NULL error:error];
	if (!navigateResult) return NO;
	if (![self updateWithNavigateHTMLData:navigateResult error:error]) return NO;
	
	NSURLRequest *firstChapterRequest = [NSURLRequest requestWithURL:[self urlForChapter:1] cachePolicy:policy timeoutInterval:5.0];
	
	NSData *firstChapterResult = [NSURLConnection sendSynchronousRequest:firstChapterRequest returningResponse:NULL error:error];
	if (!firstChapterResult) return NO;
	if (![self updateWithFirstChapterHTMLData:firstChapterResult error:error]) return NO;
	
	return YES;
}

- (BOOL)updateWithNavigateHTMLData:(NSData *)data error:(NSError * __autoreleasing *)error;
{
	NSString *dataAsUTF8 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSXMLDocument *document = [[NSXMLDocument alloc] initWithXMLString:dataAsUTF8 options:NSXMLDocumentTidyHTML error:error];
	if (!document) return NO;

	NSArray *chapterURLStrings = [document allTextsForXPath:chapterURLXPath error:error];
	self.chapterIDs = [chapterURLStrings map:^(NSString *path){
		return [NSURL URLWithString:path relativeToURL:baseURL];
	}];
	self.chapterCount = self.chapterIDs.count;
	
	return YES;
}
- (BOOL)updateWithFirstChapterHTMLData:(NSData *)data error:(NSError * __autoreleasing *)error;
{
	NSString *dataAsUTF8 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSXMLDocument *document = [[NSXMLDocument alloc] initWithXMLString:dataAsUTF8 options:NSXMLDocumentTidyHTML error:error];
	if (!document) return NO;

	self.author = [document firstTextForXPath:authorXPath error:error];
	self.authorURL = [NSURL URLWithString:[document firstTextForXPath:authorURLXPath error:error] relativeToURL:baseURL];
	self.characters = [document allTextsForXPath:charactersXPath error:error];
	self.fandoms = [document allTextsForXPath:fandomsXPath error:error];
	self.rating = [document firstTextForXPath:ratingXPath error:error];
	self.relationships = [document allTextsForXPath:relationshipsXPath error:error];
	self.summary = [document firstTextForXPath:summaryXPath error:error];
	self.title = [[document firstTextForXPath:titleXPath error:error] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	self.tags = [document allTextsForXPath:tagsXPath error:error];
	self.warnings = [document allTextsForXPath:warningsXPath error:error];
	
	NSArray *stats = [[document allTextsForXPath:statsXPath error:error] map:^(NSString *text){
		return [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	}];
	[self _parseStats:stats];
	
	if (!self.updated)
		self.updated = self.published;
	
	return YES;
}

- (void)_parseStats:(NSArray *)statsStrings
{
	NSParameterAssert((statsStrings.count % 2) == 0);
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat = @"YYYY-MM-dd";
	
	for (NSUInteger i = 0; i < statsStrings.count; i += 2)
	{
		NSString *key = [statsStrings objectAtIndex:i];
		NSString *value = [statsStrings objectAtIndex:i + 1];
		
		if ([key isEqual:@"Chapters:"])
		{
			NSArray *numbers = [value componentsSeparatedByString:@"/"];
			self.isComplete = [[numbers objectAtIndex:0] isEqual:[numbers objectAtIndex:1]];
		}
		else if ([key isEqual:@"Completed:"])
		{
			self.updated = [dateFormatter dateFromString:value];
		}
		else if ([key isEqual:@"Words:"])
		{
			self.wordCount = value.integerValue;
		}
		else if ([key isEqual:@"Published:"])
		{
			self.published = [dateFormatter dateFromString:value];
		}
	}
}

- (NSURL *)urlForChapter:(NSUInteger)chapter
{
	return [self.chapterIDs objectAtIndex:chapter - 1];
}

- (StoryChapter *)createChapterWithNumber:(NSUInteger)number;
{
	return [[StoryChapterAO3 alloc] initWithOverview:self chapterNumber:number];
}

@end
