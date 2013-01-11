//
//  StoryOverviewFF.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 11.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "StoryOverview.h"

@interface StoryOverviewFF : StoryOverview

// FF-Net specific
@property (nonatomic) NSUInteger favoriteCount;
@property (nonatomic) NSUInteger followerCount;
@property (copy, nonatomic) NSString *genre;
@property (copy, nonatomic) NSString *language;
@property (nonatomic) NSUInteger reviewCount;

@end
