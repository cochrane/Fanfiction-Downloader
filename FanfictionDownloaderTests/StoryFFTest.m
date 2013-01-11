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

@implementation StoryFFTest

- (void)setUp
{
	NSURL *testTextURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"ffteststory" withExtension:@"html"];
	self.testData = [NSData dataWithContentsOfURL:testTextURL];
}

- (void)testStoryOverview;
{
	StoryID *storyID = [[StoryID alloc] initWithID:1 site:StorySiteFFNet];
	StoryOverview *overview = [[StoryOverview alloc] initWithStoryID:storyID];
	STAssertNotNil(overview, @"Overview should exist here");
	
	NSError *error = nil;
	BOOL success = [overview updateWithHTMLData:self.testData error:&error];
	STAssertTrue(success, @"Should have worked");
	STAssertNil(error, @"Should be nil, is %@", error);
	
	STAssertEquals(overview.chapterCount, (NSUInteger)1, @"incorrect number of chapters");
	
	STAssertEqualObjects(overview.author, @"Testperson", @"incorrect author");
	STAssertEqualObjects(overview.authorURL.absoluteString, @"http://www.fanfiction.net/u/1/Testperson", @"incorrect author url");
	STAssertEqualObjects(overview.category, @"Beelzebub/べるぜバブ", @"incorrect category");
	STAssertEqualObjects(overview.categoryURL.absoluteString, @"http://www.fanfiction.net/anime/Beelzebub-%E3%81%B9%E3%82%8B%E3%81%9C%E3%83%90%E3%83%96/", @"incorrect category url");
	STAssertEquals(overview.isComplete, (BOOL) NO, @"incorrect completeness");
	STAssertEqualObjects(overview.rating, @"Fiction T", @"Incorrect rating");
	STAssertEqualObjects(overview.summary, @"A story!\n", @"incorrect summary");
	STAssertEqualObjects(overview.title, @"The Test Story", @"Incorrect title");
	STAssertEquals(overview.wordCount, (NSUInteger)20, @"incorrect word count");
	
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

	/*
	 @property (readonly, assign, nonatomic) NSUInteger favoriteCount;
	 @property (readonly, assign, nonatomic) NSUInteger followerCount;
	 @property (readonly, copy, nonatomic) NSString *genre;
	 @property (readonly, copy, nonatomic) NSURL *imageURL;
	 @property (readonly, copy, nonatomic) NSString *language;
	 @property (readonly, assign, nonatomic) NSUInteger reviewCount;
	 */
	STAssertEquals(overview.favoriteCount, (NSUInteger)7, @"favorite count is off");
	STAssertEquals(overview.followerCount, (NSUInteger)19, @"follower count is off");
	STAssertEqualObjects(overview.genre, @"Humor/Romance", @"genre is wrong");
	STAssertEqualObjects(overview.imageURL.absoluteString, @"http://ffcdn2012.fictionpressllc.netdna-cdn.com/image/507976/75/", @"image url is wrong");
	STAssertEqualObjects(overview.language, @"English", @"language wrong");
	STAssertEquals(overview.reviewCount, (NSUInteger)12, @"review count is off");
}

@end
