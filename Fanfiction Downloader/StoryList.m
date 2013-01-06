//
//  StoryList.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "StoryList.h"

#import "NSArray+Map.h"
#import "StoryListEntry.h"

@interface StoryList ()

@property (nonatomic, retain) NSMutableArray *stories;

@end

@implementation StoryList

- (id)initWithPropertyList:(id)plist;
{
	if (!(self = [super init])) return nil;
	
	NSAssert(plist == nil || [plist isKindOfClass:[NSArray class]], @"If there is a plist, it has to be a dictionary, not %@", [plist class]);
	
	self.stories = [plist mapMutable:^(id entry){ return [[StoryListEntry alloc] initWithPlist:entry]; }];
	
	return self;
}

- (id)propertyListRepresentation;
{
	return [self.stories valueForKey:@"propertyListRepresentation"];
}

- (BOOL)hasStory:(NSUInteger)storyID;
{
	for (StoryListEntry *entry in self.stories)
		if (entry.storyID == storyID) return YES;
	
	return NO;
}

- (void)addStoryIfNotExists:(NSUInteger)storyID atIndex:(NSUInteger)index errorHandler:(void(^)(NSError *))handler;
{
	if ([self hasStory:storyID]) return;
	
	StoryListEntry *entry = [[StoryListEntry alloc] initWithStoryID:storyID];
	[entry loadDisplayValuesErrorHandler:handler];
	
	[self insertObject:entry inStoriesAtIndex:index];
}

- (void)addStoryIfNotExists:(NSUInteger)storyID errorHandler:(void(^)(NSError *))handler;
{
	[self addStoryIfNotExists:storyID atIndex:[self countOfStories] errorHandler:handler];
}

- (NSUInteger)countOfStories
{
	return self.stories.count;
}
- (StoryListEntry *)objectInStoriesAtIndex:(NSUInteger)idx
{
	return [self.stories objectAtIndex:idx];
}
- (void)insertObject:(StoryListEntry *)entry inStoriesAtIndex:(NSUInteger)idx
{
	[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:idx] forKey:@"stories"];
	
	[self.stories insertObject:entry atIndex:idx];
	
	[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:idx] forKey:@"stories"];
}
- (void)removeObjectFromStoriesAtIndex:(NSUInteger)idx
{
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:[NSIndexSet indexSetWithIndex:idx] forKey:@"stories"];
	
	[self.stories removeObjectAtIndex:idx];
	
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:[NSIndexSet indexSetWithIndex:idx] forKey:@"stories"];
}
- (void)replaceObjectInStoriesAtIndex:(NSUInteger)idx withObject:(StoryListEntry *)entry
{
	[self willChange:NSKeyValueChangeReplacement valuesAtIndexes:[NSIndexSet indexSetWithIndex:idx] forKey:@"stories"];
	
	[self.stories replaceObjectAtIndex:idx withObject:entry];
	
	[self willChange:NSKeyValueChangeReplacement valuesAtIndexes:[NSIndexSet indexSetWithIndex:idx] forKey:@"stories"];
}

@end
