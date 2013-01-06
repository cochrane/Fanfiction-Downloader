//
//  StoryListEntry.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "StoryListEntry.h"

#import "StoryChapter.h"
#import "StoryOverview.h"

@interface StoryListEntry ()

@property (assign, nonatomic, readwrite) NSUInteger storyID;
@property (assign, nonatomic, readwrite) NSUInteger lastChapterCount;
@property (assign, nonatomic, readwrite) NSUInteger lastWordCount;
@property (assign, nonatomic, readwrite) BOOL isComplete;

@property (copy, nonatomic, readwrite) NSString *title;
@property (copy, nonatomic, readwrite) NSString *author;
@property (copy, nonatomic, readwrite) NSString *category;
@property (copy, nonatomic, readwrite) NSURL *imageURL;
@property (retain, nonatomic, readwrite) NSImage *image;
@property (copy, nonatomic, readwrite) NSString *summary;

- (void)loadImage;

@end

@implementation StoryListEntry

- (id)initWithPlist:(id)plist;
{
	if (!(self = [super init])) return nil;
	
	self.storyID = [[plist objectForKey:@"storyid"] unsignedIntegerValue];
	self.lastChapterCount = [[plist objectForKey:@"chapters"] unsignedIntegerValue];
	self.lastWordCount = [[plist objectForKey:@"words"] unsignedIntegerValue];
	self.chapterCountChangedSinceLastSend = [[plist objectForKey:@"chaptersChanged"] boolValue];
	self.wordCountChangedSinceLastSend = [[plist objectForKey:@"wordsChanged"] boolValue];
	
	self.title = [plist objectForKey:@"title"];
	self.author = [plist objectForKey:@"author"];
	self.category = [plist objectForKey:@"category"];
	self.imageURL = [NSURL URLWithString:[plist objectForKey:@"image"]];
	self.summary = [plist objectForKey:@"summary"];
	
	[self loadImage];
	
	return self;
}

- (id)initWithStoryID:(NSUInteger)storyID
{
	if (!(self = [super init])) return nil;
	
	self.storyID = storyID;
	
	return self;
}

- (id)propertyListRepresentation
{
	NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:8];
	
	// Always included
	[result addEntriesFromDictionary:@{
		@"storyid" : @(self.storyID),
		@"words" : @(self.lastWordCount),
		@"chapters" : @(self.lastChapterCount),
		@"chaptersChanged" : @(self.chapterCountChangedSinceLastSend),
		@"wordsChanged": @(self.wordCountChangedSinceLastSend)
	 }];
	
	// Add optional description elements
	if (self.author) [result setObject:self.author forKey:@"author"];
	if (self.category) [result setObject:self.category forKey:@"category"];
	if (self.imageURL) [result setObject:self.imageURL.absoluteString forKey:@"image"];
	if (self.summary) [result setObject:self.summary forKey:@"summary"];
	if (self.title) [result setObject:self.title forKey:@"title"];
	
	return result;
}

- (void)loadOverviewFromCache:(BOOL)useCacheWherePossible completionHandler:(void (^) (StoryOverview *overview, NSError *error))handler;
{
	NSURLCacheStoragePolicy policy = useCacheWherePossible ? NSURLRequestReturnCacheDataElseLoad : NSURLRequestReloadIgnoringLocalCacheData;
	NSURL *url = [StoryOverview urlForStoryID:self.storyID chapter:1];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:policy timeoutInterval:5.0];
	
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
		// Handle load error
		if (!data)
		{
			handler(nil, error);
			return;
		};
		
		// Get overview
		NSError *parseError = nil;
		StoryOverview *overview = [[StoryOverview alloc] initWithHTMLData:data error:&parseError];
		
		if (!overview)
		{
			handler(nil, parseError);
			return;
		}
		
		// Check whether anything changed.
		if (overview.chapterCount != self.lastChapterCount)
		{
			self.chapterCountChangedSinceLastSend = YES;
			self.lastChapterCount = overview.chapterCount;
		}
		
		if (overview.wordCount != self.lastWordCount)
		{
			self.wordCountChangedSinceLastSend = YES;
			self.lastWordCount = overview.wordCount;
		}
		
		// Update display values
		self.title = overview.title;
		self.author = overview.author;
		self.category = overview.category;
		self.imageURL = overview.imageURL;
		self.summary = overview.summary;
		self.isComplete = overview.isComplete;
		
		[self loadImage];
		
		// Inform caller
		handler(overview, error);
	}];

}

- (void)loadDisplayValuesErrorHandler:(void (^) (NSError *error)) handler;
{
	[self loadOverviewFromCache:YES completionHandler:^(StoryOverview *overview, NSError *error){
		if (error != nil && handler != NULL)
			handler(error);
	}];
}

- (NSArray *)loadChaptersFromCache:(BOOL)useCacheWherePossible error:(NSError *__autoreleasing*)error;
{
	NSURLCacheStoragePolicy policy = useCacheWherePossible ? NSURLRequestReturnCacheDataElseLoad : NSURLRequestReloadIgnoringLocalCacheData;

	NSMutableArray *chapters = [NSMutableArray arrayWithCapacity:self.lastChapterCount];
	for (NSUInteger i = 0; i < self.lastChapterCount; i++)
	{
		NSURL *chapterURL = [StoryOverview urlForStoryID:self.storyID chapter:i+1];
		
		NSURLRequest *request = [NSURLRequest requestWithURL:chapterURL cachePolicy:policy timeoutInterval:5.0];
		
		NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:NULL error:error];
		
		if (!data) return nil;
			
		StoryChapter *chapter = [[StoryChapter alloc] initWithHTMLData:data error:error];
		if (!chapter) return nil;
		
		[chapters addObject:chapter];
	}

	return chapters;
}

- (void)loadImage
{
	if (self.imageURL == nil)
	{
		self.image = nil;
		return;
	}
	
	// Use default caching here.
	NSURLRequest *request = [NSURLRequest requestWithURL:self.imageURL];
	
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
		// Handle load error
		if (!data) return;
		
		dispatch_async(dispatch_get_main_queue(), ^{
			self.image = [[NSImage alloc] initWithData:data];
		});
	}];
}

@end
