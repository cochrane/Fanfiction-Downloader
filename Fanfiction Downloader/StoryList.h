//
//  StoryList.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StoryID;
@class StoryListEntry;

@interface StoryList : NSObject <NSFilePresenter>

- (id)initWithPropertyList:(id)plist;
- (id)initWithContentsOfURL:(NSURL *)url error:(NSError *__autoreleasing*)error;

@property (nonatomic) NSURL *propertyListURL;
@property (nonatomic) BOOL isLocked;

@property (nonatomic) NSUndoManager *undoManager;

@property (nonatomic) id propertyListRepresentation;

- (BOOL)readFromFileWithError:(NSError *__autoreleasing *)error;
- (BOOL)writeToFileWithError:(NSError *__autoreleasing*)error;


- (void)addStoryIfNotExists:(StoryID *)storyID atIndex:(NSUInteger)index errorHandler:(void(^)(NSError *))handler;
- (void)addStoryIfNotExists:(StoryID *)storyID errorHandler:(void(^)(NSError *))handler;

- (BOOL)hasStory:(StoryID *)storyID;

- (NSUInteger)countOfStories;
- (StoryListEntry *)objectInStoriesAtIndex:(NSUInteger)idx;
- (void)insertObject:(StoryListEntry *)entry inStoriesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromStoriesAtIndex:(NSUInteger)idx;
- (void)replaceObjectInStoriesAtIndex:(NSUInteger)idx withObject:(StoryListEntry *)entry;

// File presenter
- (NSURL *)presentedItemURL;
- (NSOperationQueue *)presentedItemOperationQueue;

- (void)relinquishPresentedItemToReader:(void (^)(void (^reacquirer)(void)))reader;
- (void)relinquishPresentedItemToWriter:(void (^)(void (^reacquirer)(void)))writer;
- (void)savePresentedItemChangesWithCompletionHandler:(void (^)(NSError *errorOrNil))completionHandler;
- (void)accommodatePresentedItemDeletionWithCompletionHandler:(void (^)(NSError *errorOrNil))completionHandler;
- (void)presentedItemDidMoveToURL:(NSURL *)newURL;
- (void)presentedItemDidChange;


@end
