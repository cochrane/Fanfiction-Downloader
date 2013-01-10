//
//  StoryChapter.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "StoryChapter.h"

#import "NSXMLNode+QuickerXPath.h"
#import "StoryOverview.h"

static NSString *chapterTitleXPath = @"//select[@id='chap_select']//option[@selected]";
static NSString *chapterTitleRegexp = @"^(\\d+)\\. (.+)$";
static NSString *titleXPath = @"//table[@id='gui_table1i']//b[1]";

static NSString *contentXPath = @"//div[@id='storytext']";

static NSRegularExpression *chapterTitleExpression;


@interface StoryChapter ()

@property (readwrite, weak, nonatomic) StoryOverview *overview;
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

- (id)initWithOverview:(StoryOverview *)overview chapterNumber:(NSUInteger)number;
{
	NSParameterAssert(overview);
	
	if (!(self = [super init])) return nil;
	
	self.overview = overview;
	self.number = number;
	
	return self;
}

- (BOOL)updateWithHTMLData:(NSData *)data error:(NSError *__autoreleasing *)error;
{	
	NSString *dataAsUTF8 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	NSXMLDocument *document = [[NSXMLDocument alloc] initWithXMLString:dataAsUTF8 options:NSXMLDocumentTidyHTML error:error];
	if (!document) return NO;

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
	if (story == nil) return NO;
	
	// Strip all attributes from hr elements.
	NSArray *hrElements = [story nodesForXPath:@"//hr" error:error];
	[hrElements makeObjectsPerformSelector:@selector(removeAttributeForName:) withObject:@"size"];
	[hrElements makeObjectsPerformSelector:@selector(removeAttributeForName:) withObject:@"noshade"];
	
	self.text = [story XMLStringWithOptions:NSXMLDocumentTidyHTML];
	
	return YES;
}

- (BOOL)loadDataFromCache:(BOOL)useCacheWherePossible error:(NSError *__autoreleasing *)error;
{
	StoryOverview *overview = self.overview;
	
	NSURL *chapterURL = [overview urlForChapter:self.number];
	NSURLCacheStoragePolicy policy = useCacheWherePossible ? NSURLRequestReturnCacheDataElseLoad : NSURLRequestReloadIgnoringLocalCacheData;

	NSURLRequest *request = [NSURLRequest requestWithURL:chapterURL cachePolicy:policy timeoutInterval:5.0];
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:NULL error:error];
	if (!data) return NO;
	
	return [self updateWithHTMLData:data error:error];
}

@end
