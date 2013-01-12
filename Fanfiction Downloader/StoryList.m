//
//  StoryList.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "StoryList.h"

#import "NSArray+Map.h"
#import "StoryID.h"
#import "StoryListEntry.h"

@interface StoryList ()

@property (nonatomic, retain) NSMutableArray *stories;
@property (nonatomic) NSDate *fileModificationDate;
@property (nonatomic) NSOperationQueue *privateQueue;

@end

@implementation StoryList

+ (NSSet *)keyPathsForValuesAffectingPropertyListRepresentation
{
	return [NSSet setWithObject:@"stories"];
}

+ (NSSet *)keyPathsForValuesAffectingPresentedItemURL
{
	return [NSSet setWithObject:@"propertyListURL"];
}

- (id)initWithPropertyList:(id)plist;
{
	if (!(self = [super init])) return nil;
	
	[NSFileCoordinator addFilePresenter:self];
	
	self.propertyListRepresentation = plist;
	
	return self;
}
- (id)initWithContentsOfURL:(NSURL *)url error:(NSError *__autoreleasing*)error;
{
	if (!(self = [super init])) return nil;
	
	[NSFileCoordinator addFilePresenter:self];
	
	self.propertyListURL = url;
	if (![self readFromFileWithError:error])
		return nil;
	
	return self;
}

#pragma mark - File reading and writing

- (BOOL)readFromFileWithError:(NSError *__autoreleasing *)error
{
	// Special case: No file yet.
	if (!self.propertyListURL)
	{
		self.stories = [NSMutableArray array];
		return YES;
	}
	
	NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:self];
	
	__block NSError *internalError = nil;
	NSError *coordinationError = nil;
	
	[coordinator coordinateReadingItemAtURL:self.propertyListURL options:NSFileCoordinatorReadingResolvesSymbolicLink error:&coordinationError byAccessor:^(NSURL *targetURL){
		
		NSData *data = [NSData dataWithContentsOfURL:targetURL options:0 error:&internalError];
		if (!data) return;
		
		id plist = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:&internalError];
		if (!plist) return;
		
		self.propertyListRepresentation = plist;
	}];
	
	if (coordinationError)
		internalError = coordinationError;
	
	if (error != NULL)
		*error = internalError;
	
	return internalError == NULL;
}
- (BOOL)writeToFileWithError:(NSError *__autoreleasing *)error
{
	NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:self];
	
	__block NSError *internalError = nil;
	NSError *coordinationError = nil;
	
	[coordinator coordinateWritingItemAtURL:self.propertyListURL options:0 error:&coordinationError byAccessor:^(NSURL *targetURL){
		
		NSData *data = [NSPropertyListSerialization dataWithPropertyList:self.propertyListRepresentation format:NSPropertyListXMLFormat_v1_0 options:0 error:&internalError];
		[data writeToURL:targetURL options:NSDataWritingAtomic error:&internalError];
	}];
	
	if (coordinationError)
		internalError = coordinationError;
	
	if (error != NULL)
		*error = internalError;
	
	return internalError == NULL;
}

#pragma mark - Management

- (BOOL)hasStory:(StoryID *)storyID;
{
	for (StoryListEntry *entry in self.stories)
		if ([entry.storyID isEqual:storyID]) return YES;
	
	return NO;
}

- (void)addStoryIfNotExists:(StoryID *)storyID atIndex:(NSUInteger)index errorHandler:(void(^)(NSError *))handler;
{
	if ([self hasStory:storyID]) return;
	
	StoryListEntry *entry = [[StoryListEntry alloc] initWithStoryID:storyID];
	[entry loadDisplayValuesErrorHandler:handler];
	
	[self insertObject:entry inStoriesAtIndex:index];
}

- (void)addStoryIfNotExists:(StoryID *)storyID errorHandler:(void(^)(NSError *))handler;
{
	[self addStoryIfNotExists:storyID atIndex:[self countOfStories] errorHandler:handler];
}

#pragma mark - Accessors

- (void)setPropertyListRepresentation:(id)propertyListRepresentation
{
	NSAssert(propertyListRepresentation == nil || [propertyListRepresentation isKindOfClass:[NSArray class]], @"If there is a plist, it has to be an array, not %@", [propertyListRepresentation class]);
	
	self.stories = [propertyListRepresentation mapMutable:^(id entry){ return [[StoryListEntry alloc] initWithPlist:entry]; }];
}
- (id)propertyListRepresentation;
{
	return [self.stories valueForKey:@"propertyListRepresentation"];
}

- (NSUInteger)countOfStories
{
	return self.stories.count;
}
- (StoryListEntry *)objectInStoriesAtIndex:(NSUInteger)idx
{
	return [self.stories objectAtIndex:idx];
}
- (void)insertObject:(StoryListEntry *)entry inStoriesAtIndex:(NSUInteger)idx
{
	[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:idx] forKey:@"stories"];
	
	[self.stories insertObject:entry atIndex:idx];
	[[self.undoManager prepareWithInvocationTarget:self] removeObjectFromStoriesAtIndex:idx];
	
	[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:idx] forKey:@"stories"];
}
- (void)removeObjectFromStoriesAtIndex:(NSUInteger)idx
{
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:[NSIndexSet indexSetWithIndex:idx] forKey:@"stories"];
	
	StoryListEntry *oldObject = [self objectInStoriesAtIndex:idx];
	[self.stories removeObjectAtIndex:idx];
	[[self.undoManager prepareWithInvocationTarget:self] insertObject:oldObject inStoriesAtIndex:idx];
	
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:[NSIndexSet indexSetWithIndex:idx] forKey:@"stories"];
}
- (void)replaceObjectInStoriesAtIndex:(NSUInteger)idx withObject:(StoryListEntry *)entry
{
	[self willChange:NSKeyValueChangeReplacement valuesAtIndexes:[NSIndexSet indexSetWithIndex:idx] forKey:@"stories"];
	
	StoryListEntry *oldObject = [self objectInStoriesAtIndex:idx];
	[self.stories replaceObjectAtIndex:idx withObject:entry];
	[[self.undoManager prepareWithInvocationTarget:self] replaceObjectInStoriesAtIndex:idx withObject:oldObject];
	
	[self willChange:NSKeyValueChangeReplacement valuesAtIndexes:[NSIndexSet indexSetWithIndex:idx] forKey:@"stories"];
}

#pragma mark - File Presenter

- (NSURL *)presentedItemURL
{
	return self.propertyListURL;
}

- (NSOperationQueue *)presentedItemOperationQueue
{
	if (!self.privateQueue)
	{
		self.privateQueue = [[NSOperationQueue alloc] init];
		self.privateQueue.maxConcurrentOperationCount = 1;
	}
	return self.privateQueue;
}

- (void)relinquishPresentedItemToReader:(void (^)(void (^)(void)))reader
{
	[self relinquishPresentedItemToWriter:reader];
}

- (void)relinquishPresentedItemToWriter:(void (^)(void (^)(void)))writer
{
	self.isLocked = YES;
	writer(^{ self.isLocked = NO; });
}

- (void)savePresentedItemChangesWithCompletionHandler:(void (^)(NSError *))completionHandler
{
	NSError *error = NULL;
	BOOL success = [self writeToFileWithError:&error];
	
	completionHandler(success ? nil : error);
}

- (void)accommodatePresentedItemDeletionWithCompletionHandler:(void (^)(NSError *))completionHandler
{
	self.stories = [NSMutableArray array];
	completionHandler(nil);
}

- (void)presentedItemDidMoveToURL:(NSURL *)newURL
{
	self.propertyListURL = newURL;
}

- (void)presentedItemDidChange
{
	[self readFromFileWithError:NULL];
}

@end
