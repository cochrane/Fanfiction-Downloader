//
//  StoryFFTest.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 11.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "StoryFFTest.h"

#import "StoryID.h"
#import "StoryOverview.h"
#import "StoryOverviewFF.h"
#import "StoryRenderer.h"
#import "MockURLProtocol.h"

@implementation StoryFFTest

- (void)setUp
{
	NSURL *testTextURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"ffteststory" withExtension:@"html"];
	self.testData = [NSData dataWithContentsOfURL:testTextURL];
}

- (void)testStoryOverview;
{
	StoryID *storyID = [[StoryID alloc] initWithID:1 site:StorySiteFFNet];
	StoryOverviewFF *overview = (StoryOverviewFF *) [[StoryOverview alloc] initWithStoryID:storyID];
	STAssertNotNil(overview, @"Overview should exist here");
	STAssertEqualObjects(overview.className, @"StoryOverviewFF", @"Should be FF-specific subclass");
	
	NSError *error = nil;
	BOOL success = [overview updateWithHTMLData:self.testData error:&error];
	STAssertTrue(success, @"Should have worked");
	STAssertNil(error, @"Should be nil, is %@", error);
	
	STAssertEquals(overview.chapterCount, (NSUInteger)1, @"incorrect number of chapters");
	
	STAssertEqualObjects(overview.author, @"Testperson", @"incorrect author");
	STAssertEqualObjects(overview.authorURL.absoluteString, @"http://www.fanfiction.net/u/1/Testperson", @"incorrect author url");
	STAssertEqualObjects([overview.fandoms objectAtIndex:0], @"Beelzebub/べるぜバブ", @"incorrect category");
	STAssertEquals(overview.isComplete, (BOOL) NO, @"incorrect completeness");
	STAssertEqualObjects(overview.rating, @"Fiction T", @"Incorrect rating");
	STAssertEqualObjects(overview.summary, @"A story!\n", @"incorrect summary");
	STAssertEqualObjects(overview.title, @"The Test Story", @"Incorrect title");
	STAssertEquals(overview.wordCount, (NSUInteger)20, @"incorrect word count");
	
	STAssertEquals(overview.characters.count, 2UL, @"Wrong number of characters");
	STAssertEqualObjects([overview.characters objectAtIndex:0], @"Oga T.", @"First character wrong");
	STAssertEqualObjects([overview.characters objectAtIndex:1], @"Hildagarde/Hilda", @"Second character wrong");
	
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSDateComponents *published = [[NSDateComponents alloc] init];
	published.year = 2012;
	published.month = 1;
	published.day = 2;
	STAssertEqualObjects(overview.published, [calendar dateFromComponents:published], @"Published date is off");
	
	NSDateComponents *updated = [[NSDateComponents alloc] init];
	updated.year = 2012;
	updated.month = 2;
	updated.day = 2;
	STAssertEqualObjects(overview.updated, [calendar dateFromComponents:updated], @"Updated date is off");

	STAssertEquals(overview.favoriteCount, (NSUInteger)7, @"favorite count is off");
	STAssertEquals(overview.followerCount, (NSUInteger)19, @"follower count is off");
	STAssertEqualObjects(overview.genre, @"Humor/Romance", @"genre is wrong");
	STAssertEqualObjects(overview.imageURL.absoluteString, @"http://ffcdn2012.fictionpressllc.netdna-cdn.com/image/507976/75/", @"image url is wrong");
	STAssertEqualObjects(overview.language, @"English", @"language wrong");
	STAssertEquals(overview.reviewCount, (NSUInteger)12, @"review count is off");
}

- (void)testOverviewNetwork
{
	StoryID *storyID = [[StoryID alloc] initWithID:1 site:StorySiteFFNet];
	StoryOverview *overview = [[StoryOverview alloc] initWithStoryID:storyID];
	STAssertNotNil(overview, @"Overview should exist here");

	[NSURLProtocol registerClass:[MockURLProtocol class]];
	[MockURLProtocol setData:self.testData forURL:[NSURL URLWithString:@"http://fanfiction.net/s/1/1"]];
	
	NSError *loadingError = nil;
	BOOL success = [overview loadDataFromCache:NO error:&loadingError];
	STAssertTrue(success, @"Should load without trouble");
	STAssertNil(loadingError, @"Should load without error");
	
	STAssertEquals(overview.chapterCount, (NSUInteger)1, @"incorrect number of chapters");
	STAssertEqualObjects(overview.author, @"Testperson", @"incorrect author");
	
	[MockURLProtocol clearMockData];
	[NSURLProtocol unregisterClass:[MockURLProtocol class]];
}

- (void)testStoryWithoutGenre
{
	NSURL *testTextURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"ffnogenre" withExtension:@"html"];
	NSData *testData = [NSData dataWithContentsOfURL:testTextURL];

	StoryID *storyID = [[StoryID alloc] initWithID:1 site:StorySiteFFNet];
	StoryOverviewFF *overview = (StoryOverviewFF *) [[StoryOverview alloc] initWithStoryID:storyID];
	STAssertNotNil(overview, @"Overview should exist here");
	
	NSError *error = nil;
	BOOL success = [overview updateWithHTMLData:testData error:&error];
	STAssertTrue(success, @"Should have worked");
	STAssertNil(error, @"Should be nil, is %@", error);
	
	STAssertEquals(overview.chapterCount, (NSUInteger)1, @"incorrect number of chapters");

	STAssertNil(overview.genre, @"Should not have a genre");
	
	STAssertNotNil(overview.characters, @"Should have some characters");
	STAssertEquals(overview.characters.count, 2UL, @"Wrong number of characters");
	STAssertEqualObjects([overview.characters objectAtIndex:0], @"Oga T.", @"First character wrong");
	STAssertEqualObjects([overview.characters objectAtIndex:1], @"Hildagarde/Hilda", @"Second character wrong");
	
	// Check whether it renders anything
	success = [[[overview valueForKeyPath:@"chapters"] objectAtIndex:0] updateWithHTMLData:self.testData error:&error];
	STAssertTrue(success, @"Chapter updated didn't work.");
	STAssertNil(error, @"Chapter update error should be nil, is %@", error);
	
	StoryRenderer *renderer = [[StoryRenderer alloc] initWithStoryOverview:overview];
	STAssertNotNil(renderer, @"Should create renderer");
	
	NSData *resultData = renderer.renderedStory;
	STAssertNotNil(resultData, @"Did not render story");
}

@end
