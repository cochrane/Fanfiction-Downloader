//
//  StoryListEntry.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "StoryListEntry.h"

#import "NSError+AddKey.h"
#import "StoryChapter.h"
#import "StoryID.h"
#import "StoryOverview.h"

static NSOperationQueue *imageLoadingQueue;

@interface StoryListEntry ()

@property (nonatomic, readwrite) StoryID *storyID;
@property (assign, nonatomic, readwrite) NSUInteger lastChapterCount;
@property (assign, nonatomic, readwrite) NSUInteger lastWordCount;
@property (assign, nonatomic, readwrite) BOOL isComplete;

@property (copy, nonatomic, readwrite) NSString *title;
@property (copy, nonatomic, readwrite) NSString *author;
@property (copy, nonatomic, readwrite) NSString *category;
@property (copy, nonatomic, readwrite) NSURL *imageURL;
@property (retain, nonatomic, readwrite) NSImage *image;
@property (copy, nonatomic, readwrite) NSString *summary;

@property (nonatomic, readwrite) StoryOverview *overview;

- (void)loadImage;

@end

@implementation StoryListEntry

+ (void)initialize
{
	imageLoadingQueue = [[NSOperationQueue alloc] init];
	imageLoadingQueue.maxConcurrentOperationCount = 2;
}

+ (NSSet *)keyPathsForValuesAffectingErrorDescription
{
	return [NSSet setWithObject:@"updateError"];
}

- (id)initWithPlist:(id)plist;
{
	if (!(self = [super init])) return nil;
	
	if ([plist objectForKey:@"storydescription"] != nil)
	{
		self.storyID = [[StoryID alloc] initWithPropertyListRepresentation:[plist objectForKey:@"storydescription"]];
	}
	else
	{
		// Old-style representation. Means Fanfiction.net
		NSUInteger siteSpecificID = [[plist objectForKey:@"storyid"] unsignedIntegerValue];
		self.storyID = [[StoryID alloc] initWithID:siteSpecificID site:StorySiteFFNet];
	}
	
	
	self.lastChapterCount = [[plist objectForKey:@"chapters"] unsignedIntegerValue];
	self.lastWordCount = [[plist objectForKey:@"words"] unsignedIntegerValue];
	self.chapterCountChangedSinceLastSend = [[plist objectForKey:@"chaptersChanged"] boolValue];
	self.wordCountChangedSinceLastSend = [[plist objectForKey:@"wordsChanged"] boolValue];
	
	self.title = [plist objectForKey:@"title"];
	self.author = [plist objectForKey:@"author"];
	self.category = [plist objectForKey:@"category"];
	self.imageURL = [NSURL URLWithString:[plist objectForKey:@"image"]];
	self.summary = [plist objectForKey:@"summary"];
	
	self.overview = [[StoryOverview alloc] initWithStoryID:self.storyID];
	
	[self loadImage];
	
	return self;
}

- (id)initWithStoryID:(StoryID *)storyID
{
	if (!(self = [super init])) return nil;
	
	self.storyID = storyID;
	self.overview = [[StoryOverview alloc] initWithStoryID:self.storyID];
	
	return self;
}

- (id)propertyListRepresentation
{
	NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:8];
	
	// Always included
	[result addEntriesFromDictionary:@{
		@"storydescription" : self.storyID.propertyListRepresentation,
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

- (void)loadDataFromCache:(BOOL)useCacheWherePossible completionHandler:(void (^) (NSError *error))handler;
{
	if (!self.title)
		self.title = NSLocalizedString(@"Retrieving information…", @"list entry with no title");
	
	[self.overview loadDataFromCache:useCacheWherePossible completionHandler:^(NSError *error) {
		// Handle load error
		if (error)
		{
			handler([error errorByAddingUserInfoKeysAndValues:@{ @"StoryListEntry" : self }]);
			[self loadErrorImage];
			return;
		};
		
		// Check whether anything changed.
		if (self.overview.chapterCount != self.lastChapterCount)
		{
			self.chapterCountChangedSinceLastSend = YES;
			self.lastChapterCount = self.overview.chapterCount;
		}
		
		if (self.overview.wordCount != self.lastWordCount)
		{
			self.wordCountChangedSinceLastSend = YES;
			self.lastWordCount = self.overview.wordCount;
		}
		
		// Update display values
		self.title = self.overview.title;
		self.author = self.overview.author;
		self.category = [self.overview.fandoms componentsJoinedByString:@", "];
		self.imageURL = self.overview.imageURL;
		self.summary = self.overview.summary;
		self.isComplete = self.overview.isComplete;
		
		[self loadImage];
		
		// Inform caller
		handler(error);
	}];
}

- (void)loadDisplayValuesErrorHandler:(void (^) (NSError *error)) handler;
{
	[self loadDataFromCache:YES completionHandler:^(NSError *error){
		if (error != nil)
		{
			[self loadErrorImage];
			if (handler != NULL)
				handler(error);
		}
	}];
}

- (void)loadImage
{
	if (self.imageURL == nil)
	{
		self.image = nil;
		return;
	}
	
	NSURLRequest *request = [NSURLRequest requestWithURL:self.imageURL];
	
	// Check the cache first.
	NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
	if (cachedResponse)
	{
		self.image = [[NSImage alloc] initWithData:cachedResponse.data];
		return;
	}
	
	// Set up the queue, if necessary.
	// Note that all loading is done serially. Anything else risks blocks when there are too many parallel loads going on at once and thread limits get exhausted.
	
	// Send the request on the background thread.
	[imageLoadingQueue addOperationWithBlock:^{
		NSURLResponse *response;
		NSError *error;
		NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		
		if (!data) return;
		
		dispatch_async(dispatch_get_main_queue(), ^{
			self.image = [[NSImage alloc] initWithData:data];
		});
	}];
}

- (void)loadErrorImage
{
	self.image = [NSImage imageNamed:@"AlertStopIcon"];
}

- (NSString *)localizedDescription
{
	if (self.title && self.author)
		return [NSString stringWithFormat:NSLocalizedString(@"“%@” by %@", @"story description - title and author"), self.title, self.author];
	else if (self.title)
		return self.title;
	else
		return self.storyID.localizedDescription;
}

@end
