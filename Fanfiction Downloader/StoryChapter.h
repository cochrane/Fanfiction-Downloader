//
//  StoryChapter.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StoryOverview;

@interface StoryChapter : NSObject

@property (nonatomic, weak) StoryOverview *overview;
@property (nonatomic) NSUInteger number;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *startNotes;
@property (nonatomic, copy) NSString *endNotes;

- (id)initWithOverview:(StoryOverview *)overview chapterNumber:(NSUInteger)number;

- (BOOL)updateWithHTMLData:(NSData *)data error:(NSError *__autoreleasing *)error;
- (BOOL)loadDataFromCache:(BOOL)useCacheWherePossible error:(NSError *__autoreleasing *)error;
;

@end
