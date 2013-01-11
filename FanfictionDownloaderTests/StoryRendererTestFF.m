//
//  StoryRendererTestFF.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 11.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "StoryRendererTestFF.h"

#import "StoryID.h"
#import "StoryOverview.h"
#import "StoryRenderer.h"

@implementation StoryRendererTestFF

- (void)setUp
{
	NSURL *testTextURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"ffteststory" withExtension:@"html"];
	self.testData = [NSData dataWithContentsOfURL:testTextURL];
}

- (void)testStandardStory
{
	NSURL *expectedURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"ffteststory.expected" withExtension:@"html"];
	NSString *expected = [NSString stringWithContentsOfURL:expectedURL encoding:NSUTF8StringEncoding error:NULL];
	
	StoryID *storyID = [[StoryID alloc] initWithID:1 site:StorySiteFFNet];
	StoryOverview *overview = [[StoryOverview alloc] initWithStoryID:storyID];
	STAssertNotNil(overview, @"Overview should exist here");
	
	NSError *error = nil;
	BOOL success = [overview updateWithHTMLData:self.testData error:&error];
	STAssertTrue(success, @"Overview updated didn't work.");
	STAssertNil(error, @"Overview update error should be nil, is %@", error);
	
	success = [[[overview valueForKeyPath:@"chapters"] objectAtIndex:0] updateWithHTMLData:self.testData error:&error];
	STAssertTrue(success, @"Chapter updated didn't work.");
	STAssertNil(error, @"Chapter update error should be nil, is %@", error);

	StoryRenderer *renderer = [[StoryRenderer alloc] initWithStoryOverview:overview];
	STAssertNotNil(renderer, @"Should create renderer");
	
	NSData *resultData = renderer.renderedStory;
	STAssertNotNil(resultData, @"Did not render story");
	
	NSString *result = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
	STAssertEqualObjects(result, expected, @"Result did not match what was expected");
}

@end
