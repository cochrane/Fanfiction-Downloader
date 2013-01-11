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
		NSDictionary *values = @{
			@"number" : [chapterNumberFormatter stringFromNumber:@(chapter.number)],
			@"title" : chapter.title,
			@"text" : chapter.text
		};
		
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
								   @"category" : self.overview.category,
								   @"categoryURL" : self.overview.categoryURL.absoluteString,
								   @"favoriteCount" : [countNumberFormatter stringFromNumber:@(self.overview.favoriteCount)],
								   @"followerCount" : [countNumberFormatter stringFromNumber:@(self.overview.followerCount)],
								   @"isComplete" : self.overview.isComplete ? NSLocalizedString(@"Complete", @"story status") : NSLocalizedString(@"In progress", @"story status"),
								   @"language" : self.overview.language,
								   @"published" : [dateFormatter stringFromDate:self.overview.published],
								   @"rating" : self.overview.rating,
								   @"reviewCount" : [countNumberFormatter stringFromNumber:@(self.overview.reviewCount)],
								   @"summary" : self.overview.summary,
								   @"title" : self.overview.title,
								   @"updated" : [dateFormatter stringFromDate:self.overview.updated],
								   @"wordCount" : [countNumberFormatter stringFromNumber:@(self.overview.wordCount)] }];
	
	if ([self.overview respondsToSelector:@selector(genre)] && [self.overview genre])
		[values setObject:[self.overview genre] forKey:@"genre"];
	
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
