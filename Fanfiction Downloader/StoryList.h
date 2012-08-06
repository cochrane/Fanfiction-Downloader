//
//  StoryList.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StoryListEntry;

@interface StoryList : NSObject

- (id)initWithPropertyList:(id)plist;

- (id)writeToPropertyList;


- (void)addStoryIfNotExists:(NSUInteger)storyID atIndex:(NSUInteger)index errorHandler:(void(^)(NSError *))handler;
- (void)addStoryIfNotExists:(NSUInteger)storyID errorHandler:(void(^)(NSError *))handler;

- (BOOL)hasStory:(NSUInteger)storyID;

- (NSUInteger)countOfStories;
- (StoryListEntry *)objectInStoriesAtIndex:(NSUInteger)idx;
- (void)insertObject:(StoryListEntry *)entry inStoriesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromStoriesAtIndex:(NSUInteger)idx;
- (void)replaceObjectInStoriesAtIndex:(NSUInteger)idx withObject:(StoryListEntry *)entry;

@end
