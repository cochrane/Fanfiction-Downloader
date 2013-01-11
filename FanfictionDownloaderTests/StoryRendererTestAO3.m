//
//  StoryRendererTestAO3.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 11.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "StoryRendererTestAO3.h"

#import "MockURLProtocol.h"
#import "StoryID.h"
#import "StoryOverview.h"
#import "StoryRenderer.h"

@implementation StoryRendererTestAO3

- (void)setUp
{
	[NSURLProtocol registerClass:[MockURLProtocol class]];

	NSURL *navigateURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"ao3teststory.navigate" withExtension:@"html"];
	NSData *navigateData = [NSData dataWithContentsOfURL:navigateURL];
	
	[MockURLProtocol setData:navigateData forURL:[NSURL URLWithString:@"http://archiveofourown.org/works/1/navigate"]];
	
	
	NSURL *chapterURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"ao3teststory.chapter" withExtension:@"html"];
	NSData *chapterData = [NSData dataWithContentsOfURL:chapterURL];
	
	[MockURLProtocol setData:chapterData forURL:[NSURL URLWithString:@"http://archiveofourown.org/works/1/chapters/23"]];
}

- (void)tearDown
{
	[MockURLProtocol clearMockData];
	[NSURLProtocol unregisterClass:[MockURLProtocol class]];
}

- (void)testStandardStory
{
	NSURL *expectedURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"ao3teststory.expected" withExtension:@"html"];
	NSString *expected = [NSString stringWithContentsOfURL:expectedURL encoding:NSUTF8StringEncoding error:NULL];
	
	StoryID *storyID = [[StoryID alloc] initWithID:1 site:StorySiteAO3];
	StoryOverview *overview = [[StoryOverview alloc] initWithStoryID:storyID];
	STAssertNotNil(overview, @"Overview should exist here");
	
	NSError *error = nil;
	BOOL success = [overview loadDataFromCache:NO error:&error];
	STAssertTrue(success, @"Overview updated didn't work.");
	STAssertNil(error, @"Overview update error should be nil, is %@", error);
	
	error = nil;
	success = [[[overview valueForKeyPath:@"chapters"] objectAtIndex:0] loadDataFromCache:NO error:&error];
	STAssertTrue(success, @"Chapter update didn't work.");
	STAssertNil(error, @"Chapter update error should be nil, is %@", error);
	
	StoryRenderer *renderer = [[StoryRenderer alloc] initWithStoryOverview:overview];
	STAssertNotNil(renderer, @"Should create renderer");
	
	NSData *resultData = renderer.renderedStory;
	STAssertNotNil(resultData, @"Did not render story");
	
	NSString *result = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
	STAssertEqualObjects(result, expected, @"Result did not match what was expected");
}


@end
