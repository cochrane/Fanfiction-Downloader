//
//  StoryOverviewTest.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 11.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "StoryOverviewTest.h"

#import "StoryOverview.h"

@implementation StoryOverviewTest

- (void)testNilStoryID
{
	StoryOverview *overview = nil;
	STAssertThrows(overview = [[StoryOverview alloc] initWithStoryID:nil], @"Should complain about nil storyID");
	STAssertNil(overview, @"Should not create storyID");
}

@end
