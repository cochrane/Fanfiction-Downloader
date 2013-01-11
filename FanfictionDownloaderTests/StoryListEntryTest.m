//
//  StoryListEntryTest.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 11.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "StoryListEntryTest.h"

#import "StoryID.h"
#import "StoryListEntry.h"
#import "StoryOverview.h"

@implementation StoryListEntryTest

- (void)testCreationWithOnlyID
{
	StoryID *storyID = [[StoryID alloc] initWithID:12 site:StorySiteFFNet];
	
	StoryListEntry *entry = [[StoryListEntry alloc] initWithStoryID:storyID];
	
	STAssertNotNil(entry, @"Should be created");
	STAssertNotNil(entry.storyID, @"ID should be set");
	STAssertNotNil(entry.overview, @"overview should be created");
	STAssertNotNil(entry.overview.storyID, @"Overview must have storyID");
}

@end
