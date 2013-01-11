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

@implementation StoryChapter

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
	[self doesNotRecognizeSelector:_cmd];
	return NO;
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
