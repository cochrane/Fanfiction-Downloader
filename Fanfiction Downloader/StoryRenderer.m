//
//  StoryRenderer.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "StoryRenderer.h"

#import "FileTemplate.h"
#import "StoryChapter.h"
#import "StoryOverview.h"
#import "StoryOverviewAO3.h"
#import "StoryOverviewFF.h"

static FileTemplate *tocTemplate;
static FileTemplate *chapterTemplate;
static FileTemplate *storyTemplate;

@interface StoryRenderer ()

@property (retain, nonatomic) StoryOverview *overview;

@end

@implementation StoryRenderer

+ (void)initialize
{
	NSString *tocTemplateText = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"tocTemplate" withExtension:@"html"] encoding:NSUTF8StringEncoding error:NULL];
	tocTemplate = [[FileTemplate alloc] initWithTemplateString:tocTemplateText startMarker:@"{{" endMarker:@"}}"];
	
	NSString *chapterTemplateText = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"chapterTemplate" withExtension:@"html"] encoding:NSUTF8StringEncoding error:NULL];
	chapterTemplate = [[FileTemplate alloc] initWithTemplateString:chapterTemplateText startMarker:@"{{" endMarker:@"}}"];
	
	NSString *storyTemplateText = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"storyTemplate" withExtension:@"html"] encoding:NSUTF8StringEncoding error:NULL];
	storyTemplate = [[FileTemplate alloc] initWithTemplateString:storyTemplateText startMarker:@"{{" endMarker:@"}}"];
}

- (id)initWithStoryOverview:(StoryOverview *)overview;
{
	NSParameterAssert(overview);
	
	if (!(self = [super init])) return nil;
	
	self.overview = overview;
	
	return self;
}

- (NSData *)renderedStory;
{
	NSMutableString *tableOfContents = [NSMutableString string];
	NSMutableString *chapters = [NSMutableString string];
	
	NSLocale *usEnglish = [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
	
	NSNumberFormatter *chapterNumberFormatter = [[NSNumberFormatter alloc] init];
	chapterNumberFormatter.numberStyle = NSNumberFormatterNoStyle;
	chapterNumberFormatter.locale = usEnglish;
	
	NSNumberFormatter *countNumberFormatter = [[NSNumberFormatter alloc] init];
	countNumberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
	countNumberFormatter.locale = usEnglish;
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateStyle = NSDateFormatterLongStyle;
	dateFormatter.locale = usEnglish;
	
	for (StoryChapter *chapter in [self.overview valueForKey:@"chapters"])
	{
		NSMutableDictionary *values = [NSMutableDictionary dictionaryWithDictionary:@{
			@"number" : [chapterNumberFormatter stringFromNumber:@(chapter.number)],
			@"title" : chapter.title,
			@"text" : chapter.text
		}];
		
		if (chapter.startNotes)
			[values setObject:chapter.startNotes forKey:@"startnotes"];
		if (chapter.endNotes)
			[values setObject:chapter.endNotes forKey:@"endnotes"];
		
		[tableOfContents appendString:[tocTemplate instantiateWithValues:values]];
		
		[chapters appendString:[chapterTemplate instantiateWithValues:values]];
	}
	
	NSMutableDictionary *values = [NSMutableDictionary dictionaryWithDictionary:@{
								   @"toc" : tableOfContents,
								   @"chapters" : chapters,
								   
								   @"author" : self.overview.author,
								   @"authorURL" : self.overview.authorURL.absoluteString,
								   @"chapterCount" : [countNumberFormatter stringFromNumber:@(self.overview.chapterCount)],
								   @"characters" : [self.overview.characters componentsJoinedByString:@", "],
								   @"fandoms" : [self.overview.fandoms componentsJoinedByString:@", "],
								   @"isComplete" : self.overview.isComplete ? NSLocalizedString(@"Complete", @"story status") : NSLocalizedString(@"In progress", @"story status"),
								   @"published" : [dateFormatter stringFromDate:self.overview.published],
								   @"rating" : self.overview.rating,
								   @"summary" : self.overview.summary,
								   @"title" : self.overview.title,
								   @"updated" : [dateFormatter stringFromDate:self.overview.updated],
								   @"wordCount" : [countNumberFormatter stringFromNumber:@(self.overview.wordCount)] }];
	
	if ([self.overview isKindOfClass:[StoryOverviewAO3 class]])
	{
		StoryOverviewAO3 *ao3Overview = (StoryOverviewAO3 *) self.overview;
		
		[values addEntriesFromDictionary:@{
		 @"relationships" : [ao3Overview.relationships componentsJoinedByString:@", "],
		 @"tags" : [ao3Overview.tags componentsJoinedByString:@", "],
		 @"warnings": [ao3Overview.warnings componentsJoinedByString:@", "]
		 }];
	}
	if ([self.overview isKindOfClass:[StoryOverviewFF class]])
	{
		StoryOverviewFF *ffOverview = (StoryOverviewFF *) self.overview;
		
		[values addEntriesFromDictionary:@{
		 @"favoriteCount" : [countNumberFormatter stringFromNumber:@(ffOverview.favoriteCount)],
		 @"followerCount" : [countNumberFormatter stringFromNumber:@(ffOverview.followerCount)],
		 @"language" : ffOverview.language,
		 @"reviewCount" : [countNumberFormatter stringFromNumber:@(ffOverview.reviewCount)],
		 }];
		
		if (ffOverview.genre)
			[values setObject:ffOverview.genre forKey:@"genre"];
	}
	
	
	NSString *result = [storyTemplate instantiateWithValues:values];
	
	return [result dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)author
{
	return self.overview.author;
}

- (NSString *)title
{
	return self.overview.title;
}

- (NSString *)summary
{
	return self.overview.summary;
}

@end
