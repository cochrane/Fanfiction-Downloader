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
- (BOOL)loadDataFromCache:(BOOL)useCacheWherePossible error:(NSError *__autoreleasing *)error;
- (BOOL)loadChapterDataFromCache:(BOOL)useCacheWherePossible error:(NSError *__autoreleasing*)error;
- (BOOL)updateWithHTMLData:(NSData *)data error:(NSError *__autoreleasing *)error;

// Necessary and with special functions
@property (nonatomic) NSUInteger chapterCount;
@property (nonatomic) StoryID *storyID;

// Common (though actual text values may differ between sites)
@property (copy, nonatomic) NSString *author;
@property (copy, nonatomic) NSURL *authorURL;
@property (copy, nonatomic) NSString *category;
@property (copy, nonatomic) NSURL *categoryURL;
@property (nonatomic) BOOL isComplete;
@property (copy, nonatomic) NSDate *published;
@property (copy, nonatomic) NSString *rating;
@property (copy, nonatomic) NSString *summary;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSDate *updated;
@property (nonatomic) NSUInteger wordCount;

// Unsure what to do with these and stuff 
@property (copy, nonatomic) NSArray *characters;

// FF-Net specific
@property (nonatomic) NSUInteger favoriteCount;
@property (nonatomic) NSUInteger followerCount;
@property (copy, nonatomic) NSString *genre;
@property (copy, nonatomic) NSURL *imageURL;
@property (copy, nonatomic) NSString *language;
@property (nonatomic) NSUInteger reviewCount;

- (NSURL *)urlForChapter:(NSUInteger)chapter;

- (NSUInteger)countOfChapters;
- (StoryChapter *)objectInChaptersAtIndex:(NSUInteger)index;
- (void)insertObject:(StoryChapter *)object inChaptersAtIndex:(NSUInteger)index;
- (void)removeObjectFromChaptersAtIndex:(NSUInteger)index;

// Create specific chapter subclass.
- (StoryChapter *)createChapterWithNumber:(NSUInteger)number;

@end
