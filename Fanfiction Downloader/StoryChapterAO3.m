//
//  StoryChapterAO3.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 11.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "StoryChapterAO3.h"

#import "NSXMLNode+QuickerXPath.h"

static NSString *titleXPath = @"//div[@class='chapter preface group']/h3[@class='title'][1]";
static NSString *textXPath = @"//div[@class='userstuff module'][1]";
static NSString *endNotesXPath = @"//div[@id='work_endnotes']/blockquote[@class='userstuff'][1]/*";

@implementation StoryChapterAO3

- (BOOL)updateWithHTMLData:(NSData *)data error:(NSError *__autoreleasing *)error
{
	// Create document. Turn into string by hand, since NSXMLDocument can't deal with HTML5-style encoding declarations.
	NSString *dataAsUTF8 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSXMLDocument *document = [[NSXMLDocument alloc] initWithXMLString:dataAsUTF8 options:NSXMLDocumentTidyHTML error:error];
	if (!document) return NO;

	self.title = [document firstTextForXPath:titleXPath error:error];
	self.endNotes = [document allTextForXPath:endNotesXPath error:error];
	
	// Remove the first element, which is an H3 element containing simply the heading Chapter Text
	NSXMLElement *textElement = (NSXMLElement *)[document firstNodeForXPath:textXPath error:error];
	NSUInteger firstElementIndex = 0;
	while ([textElement childAtIndex:firstElementIndex].kind != NSXMLElementKind)
		firstElementIndex += 1;
	[textElement removeChildAtIndex:firstElementIndex];
	
	self.text = [textElement XMLStringWithOptions:NSXMLDocumentTidyHTML];
	
	return YES;
}

@end
