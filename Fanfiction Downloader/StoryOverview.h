//
//  StoryOverview.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StoryOverview : NSObject

- (id)initWithHTMLData:(NSData *)data error:(NSError * __autoreleasing *)error;

@property (readonly, assign, nonatomic) NSUInteger storyID;

@property (readonly, copy, nonatomic) NSString *author;
@property (readonly, copy, nonatomic) NSURL *authorURL;
@property (readonly, assign, nonatomic) NSUInteger chapterCount;
@property (readonly, copy, nonatomic) NSString *characters;
@property (readonly, copy, nonatomic) NSString *category;
@property (readonly, copy, nonatomic) NSURL *categoryURL;
@property (readonly, assign, nonatomic) NSUInteger favoriteCount;
@property (readonly, assign, nonatomic) NSUInteger followerCount;
@property (readonly, copy, nonatomic) NSString *genre;
@property (readonly, copy, nonatomic) NSURL *imageURL;
@property (readonly, assign, nonatomic) BOOL isComplete;
@property (readonly, copy, nonatomic) NSString *language;
@property (readonly, copy, nonatomic) NSDate *published;
@property (readonly, copy, nonatomic) NSString *rating;
@property (readonly, assign, nonatomic) NSUInteger reviewCount;
@property (readonly, copy, nonatomic) NSString *summary;
@property (readonly, copy, nonatomic) NSString *title;
@property (readonly, copy, nonatomic) NSDate *updated;

@property (readonly, assign, nonatomic) NSUInteger wordCount;

+ (NSURL *)urlForStoryID:(NSUInteger)story chapter:(NSUInteger)chapter;
- (NSURL *)urlForChapter:(NSUInteger)chapter;
+ (BOOL)URLisValidForStory:(NSURL *)storyURL errorDescription:(NSError * __autoreleasing *)error;
+ (BOOL)URLisValidAndExistsForStory:(NSURL *)storyURL errorDescription:(NSError * __autoreleasing *)error;
+ (NSUInteger)storyIDFromURL:(NSURL *)url;

@end
