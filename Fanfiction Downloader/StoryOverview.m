//
//  StoryOverview.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "StoryOverview.h"

#import "NSXMLNode+QuickerXPath.h"
#import "StoryChapter.h"
#import "StoryID.h"
#import "StoryOverviewAO3.h"
#import "StoryOverviewFF.h"

static NSOperationQueue *textLoadingQueue;

@interface StoryOverview ()
{
	NSMutableArray *_chapters;
}

@end

@implementation StoryOverview

+ (void)initialize
{
	textLoadingQueue = [[NSOperationQueue alloc] init];
	textLoadingQueue.maxConcurrentOperationCount = 4;
}

- (id)initWithStoryID:(StoryID *)storyID;
{
	NSParameterAssert(storyID);
	
	switch (storyID.site)
	{
		case StorySiteFFNet:
			self = [[StoryOverviewFF alloc] init];
			break;
		case StorySiteAO3:
			self = [[StoryOverviewAO3 alloc] init];
			break;
		default:
			return nil;
	}
	if (!self) return nil;
	
	_storyID = storyID;
	_chapters = [NSMutableArray array];
	
	return self;
}

- (BOOL)updateWithHTMLData:(NSData *)data error:(NSError *__autoreleasing *)error;
{
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

- (void)loadDataFromCache:(BOOL)useCacheWherePossible completionHandler:(void (^) (NSError *error))handler;
{
	[textLoadingQueue addOperationWithBlock:^{
		NSError *error = nil;
		BOOL success = [self loadDataFromCache:useCacheWherePossible error:&error];
		
		dispatch_async(dispatch_get_main_queue(), ^(){
			handler(success ? nil : error);
		});
	}];
}

- (BOOL)loadDataFromCache:(BOOL)useCacheWherePossible error:(NSError *__autoreleasing *)error;
{
	NSURLCacheStoragePolicy policy = useCacheWherePossible ? NSURLRequestReturnCacheDataElseLoad : NSURLRequestReloadIgnoringLocalCacheData;
	
	NSURLRequest *request = [NSURLRequest requestWithURL:self.storyID.overviewURL cachePolicy:policy timeoutInterval:5.0];
	
	NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:NULL error:error];
	if (!result) return NO;
	return [self updateWithHTMLData:result error:error];
}
- (BOOL)loadChapterDataFromCache:(BOOL)useCacheWherePossible error:(NSError *__autoreleasing*)error;
{
	for (StoryChapter *chapter in [self valueForKey:@"chapters"])
	{
		BOOL success = [chapter loadDataFromCache:useCacheWherePossible error:error];
		if (!success) return NO;
	}
	return YES;
}

- (NSURL *)urlForChapter:(NSUInteger)chapter
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (void)setChapterCount:(NSUInteger)chapterCount
{
	_chapterCount = chapterCount;
	
	NSMutableArray *chapters = [self mutableArrayValueForKey:@"chapters"];
	if (chapterCount > chapters.count)
	{
		for (NSUInteger i = chapters.count; i < chapterCount; ++i)
			[chapters addObject:[self createChapterWithNumber:i + 1]];
	}
	else if (chapterCount < chapters.count)
	{
		[chapters removeObjectsInRange:NSMakeRange(chapterCount, chapters.count - chapterCount)];
	}
}

- (StoryChapter *)createChapterWithNumber:(NSUInteger)number;
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

#pragma mark - Chapter accessors

- (NSUInteger)countOfChapters;
{
	return _chapters.count;
}
- (StoryChapter *)objectInChaptersAtIndex:(NSUInteger)index;
{
	return [_chapters objectAtIndex:index];
}
- (void)insertObject:(StoryChapter *)object inChaptersAtIndex:(NSUInteger)index;
{
	[_chapters insertObject:object atIndex:index];
}
- (void)removeObjectFromChaptersAtIndex:(NSUInteger)index;
{
	[_chapters removeObjectAtIndex:index];
}

@end
