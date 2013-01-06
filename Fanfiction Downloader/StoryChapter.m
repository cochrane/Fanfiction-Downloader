//
//  StoryChapter.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "StoryChapter.h"

#import "NSXMLNode+QuickerXPath.h"

static NSString *chapterTitleXPath = @"//select[@id='chap_select']//option[@selected]";
static NSString *chapterTitleRegexp = @"^(\\d+)\\. (.+)$";
static NSString *titleXPath = @"//table[@id='gui_table1i']//b[1]";

static NSString *contentXPath = @"//div[@id='storytext']";

static NSRegularExpression *chapterTitleExpression;


@interface StoryChapter ()

@property (readwrite, assign, nonatomic) NSUInteger number;
@property (readwrite, copy, nonatomic) NSString *title;
@property (readwrite, copy, nonatomic) NSString *text;

@end


@implementation StoryChapter

+ (void)initialize
{
	NSError *error = nil;
	chapterTitleExpression = [NSRegularExpression regularExpressionWithPattern:chapterTitleRegexp options:0 error:&error];
	NSAssert(chapterTitleExpression != nil, @"Chapter title regular expression could not be created. Reason: %@", error);
}

- (id)initWithHTMLData:(NSData *)data error:(NSError * __autoreleasing *)error
{
	if (!(self = [super init])) return nil;
	
	NSString *dataAsUTF8 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	NSXMLDocument *document = [[NSXMLDocument alloc] initWithXMLString:dataAsUTF8 options:NSXMLDocumentTidyHTML error:error];
	if (!document) return nil;

	// Find chapter title
	NSString *chapterLabel = [document firstTextForXPath:chapterTitleXPath error:error];
	if (chapterLabel)
	{
		NSTextCheckingResult *checkResult = [chapterTitleExpression firstMatchInString:chapterLabel options:0 range:NSMakeRange(0, chapterLabel.length)];
	
		NSString *chapterNumber = [chapterLabel substringWithRange:[checkResult rangeAtIndex:1]];
		NSString *chapterTitle = [chapterLabel substringWithRange:[checkResult rangeAtIndex:2]];
		self.number = (NSUInteger) [chapterNumber integerValue];
		self.title = chapterTitle;
	}
	else
	{
		self.number = 1;
		self.title = [document firstTextForXPath:titleXPath error:error];
	}
	
	
	NSXMLNode *story = [document firstNodeForXPath:contentXPath error:error];
	if (story == nil) return nil;
	
	// Strip all attributes from hr elements.
	NSArray *hrElements = [story nodesForXPath:@"//hr" error:error];
	[hrElements makeObjectsPerformSelector:@selector(removeAttributeForName:) withObject:@"size"];
	[hrElements makeObjectsPerformSelector:@selector(removeAttributeForName:) withObject:@"noshade"];
	
	self.text = [story XMLStringWithOptions:NSXMLDocumentTidyHTML];
	
	return self;
}

@end
