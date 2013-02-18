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
#import "StoryID.h"

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
	if (!data)
	{
		if (error && !*error)
		{
			*error = [NSError errorWithDomain:@"StoryChapter" code:1 userInfo:@{
				   NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Could not load chapter %lu of story %lu on %@", @"loadDataFromCache:error: failed"), self.number, overview.storyID.siteSpecificID, overview.storyID.localizedSiteName],
				   NSLocalizedDescriptionKey : NSLocalizedString(@"The story may have been deleted", @"loadDataFromCache:error: failed"),
					  }];
		}
		return NO;
	}
	
	return [self updateWithHTMLData:data error:error];
}

@end
