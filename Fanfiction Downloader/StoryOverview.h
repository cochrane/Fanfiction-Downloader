//
//  StoryOverview.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StoryChapter;
@class StoryID;

@interface StoryOverview : NSObject

// Note: Do not call this from subclasses!
- (id)initWithStoryID:(StoryID *)storyID;

- (void)loadDataFromCache:(BOOL)useCacheWherePossible completionHandler:(void (^) (NSError *error))handler;
- (BOOL)loadChapterDataFromCache:(BOOL)useCacheWherePossible error:(NSError *__autoreleasing*)error;
- (BOOL)updateWithHTMLData:(NSData *)data error:(NSError *__autoreleasing *)error;

// Necessary and with special functions
@property (readonly, assign, nonatomic) NSUInteger chapterCount;
@property (readonly, nonatomic) StoryID *storyID;

// Common (though actual text values may differ between sites)
@property (readonly, copy, nonatomic) NSString *author;
@property (readonly, copy, nonatomic) NSURL *authorURL;
@property (readonly, copy, nonatomic) NSString *category;
@property (readonly, copy, nonatomic) NSURL *categoryURL;
@property (readonly, assign, nonatomic) BOOL isComplete;
@property (readonly, copy, nonatomic) NSDate *published;
@property (readonly, copy, nonatomic) NSString *rating;
@property (readonly, copy, nonatomic) NSString *summary;
@property (readonly, copy, nonatomic) NSString *title;
@property (readonly, copy, nonatomic) NSDate *updated;
@property (readonly, assign, nonatomic) NSUInteger wordCount;

// Unsure what to do with these and stuff 
@property (readonly, copy, nonatomic) NSString *characters;

// FF-Net specific
@property (readonly, assign, nonatomic) NSUInteger favoriteCount;
@property (readonly, assign, nonatomic) NSUInteger followerCount;
@property (readonly, copy, nonatomic) NSString *genre;
@property (readonly, copy, nonatomic) NSURL *imageURL;
@property (readonly, copy, nonatomic) NSString *language;
@property (readonly, assign, nonatomic) NSUInteger reviewCount;

- (NSURL *)urlForChapter:(NSUInteger)chapter;

- (NSUInteger)countOfChapters;
- (StoryChapter *)objectInChaptersAtIndex:(NSUInteger)index;
- (void)insertObject:(StoryChapter *)object inChaptersAtIndex:(NSUInteger)index;
- (void)removeObjectFromChaptersAtIndex:(NSUInteger)index;

@end
