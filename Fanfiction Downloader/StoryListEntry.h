//
//  StoryListEntry.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StoryChapter;
@class StoryID;
@class StoryOverview;

@interface StoryListEntry : NSObject

// Read initial values from property list.
- (id)initWithPlist:(id)plist;
- (id)propertyListRepresentation;

// Do not use any initial values at all.
- (id)initWithStoryID:(StoryID *)storyID;
- (void)loadDisplayValuesErrorHandler:(void (^) (NSError *error)) handler;

@property (nonatomic, readonly) StoryID *storyID;

@property (assign, nonatomic, readonly) NSUInteger lastChapterCount;
@property (assign, nonatomic, readonly) NSUInteger lastWordCount;
@property (assign, nonatomic, readonly) BOOL isComplete;

@property (assign, nonatomic) BOOL chapterCountChangedSinceLastSend;
@property (assign, nonatomic) BOOL wordCountChangedSinceLastSend;

@property (copy, nonatomic, readonly) NSString *title;
@property (copy, nonatomic, readonly) NSString *author;
@property (copy, nonatomic, readonly) NSString *category;
@property (copy, nonatomic, readonly) NSURL *imageURL;
@property (retain, nonatomic, readonly) NSImage *image;
@property (copy, nonatomic, readonly) NSString *summary;

@property (nonatomic, readonly) StoryOverview *overview;

- (void)loadDataFromCache:(BOOL)useCacheWherePossible completionHandler:(void (^) (NSError *error))handler;

@end
