//
//  StoryOverviewAO3.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 11.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "StoryOverview.h"

@interface StoryOverviewAO3 : StoryOverview

@property (nonatomic) NSArray *relationships;
@property (nonatomic) NSArray *tags;
@property (nonatomic) NSArray *warnings;

- (BOOL)updateWithNavigateHTMLData:(NSData *)data error:(NSError * __autoreleasing *)error;
- (BOOL)updateWithFirstChapterHTMLData:(NSData *)data error:(NSError * __autoreleasing *)error;

@end
