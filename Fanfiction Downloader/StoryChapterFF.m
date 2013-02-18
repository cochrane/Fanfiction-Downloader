//
//  StoryChapterFF.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 11.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "StoryChapterFF.h"

#import "NSXMLNode+QuickerXPath.h"
#import "StoryOverview.h"
#import "StoryID.h"

static NSString *chapterTitleXPath = @"//select[@id='chap_select']//option[@selected]";
static NSString *chapterTitleRegexp = @"^(\\d+)\\. (.+)$";
static NSString *titleXPath = @"//table[@id='gui_table1i']//b[1]";

static NSString *contentXPath = @"//div[@id='storytext']";

static NSString *warningXPath = @"//span[@class='gui_warning']";

static NSRegularExpression *chapterTitleExpression;

@implementation StoryChapterFF

+ (void)initialize
{
	NSError *error = nil;
	chapterTitleExpression = [NSRegularExpression regularExpressionWithPattern:chapterTitleRegexp options:0 error:&error];
	NSAssert(chapterTitleExpression != nil, @"Chapter title regular expression could not be created. Reason: %@", error);
}

- (BOOL)updateWithHTMLData:(NSData *)data error:(NSError *__autoreleasing *)error;
{
	// Create document. Turn into string by hand, since NSXMLDocument can't deal with HTML5-style encoding declarations.
	NSString *dataAsUTF8 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSXMLDocument *document = [[NSXMLDocument alloc] initWithXMLString:dataAsUTF8 options:NSXMLDocumentTidyHTML error:error];
	if (!document)
		return NO;
	
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
	
	// Find story
	NSXMLNode *story = [document firstNodeForXPath:contentXPath error:error];
	if (story == nil)
	{
		NSString *errorMessage = [document allTextForXPath:warningXPath error:error];
		if (errorMessage && error && !*error)
		{
			StoryOverview *overview = self.overview;
			*error = [NSError errorWithDomain:@"FF" code:1 userInfo:@{
				   NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Did not find text for chapter %lu of story %lu on Fanfiction.net", @"story node not found"), self.number, overview.storyID.siteSpecificID],
	   NSLocalizedRecoverySuggestionErrorKey : [NSString stringWithFormat:NSLocalizedString(@"The site reported the error: “%@”", errorMessage), errorMessage]
					  }];
		}
		return NO;
	}
	
	// Strip all attributes from hr elements.
	NSArray *hrElements = [story nodesForXPath:@"//hr" error:error];
	[hrElements makeObjectsPerformSelector:@selector(removeAttributeForName:) withObject:@"size"];
	[hrElements makeObjectsPerformSelector:@selector(removeAttributeForName:) withObject:@"noshade"];
	
	self.text = [story XMLStringWithOptions:NSXMLDocumentTidyHTML];
	
	return YES;
}

@end
