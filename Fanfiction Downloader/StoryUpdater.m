//
//  StoryUpdater.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "StoryUpdater.h"

#import "NSError+AddKey.h"
#import "StoryChapter.h"
#import "StoryList.h"
#import "StoryListEntry.h"
#import "StoryOverview.h"
#import "StoryRenderer.h"
#import "EmailSender.h"

@interface StoryUpdater ()

- (void)updateStories:(NSArray *)stories onlyIfNeeded:(BOOL)ifNeeded;

@end

@implementation StoryUpdater

- (void)updateStories:(NSArray *)stories onlyIfNeeded:(BOOL)onlyIfNeeded;
{
	_storiesToUpdate = [stories count];
	_storiesUpdatedSoFar = 0;
	
	for (StoryListEntry *entry in stories)
	{
		[entry loadDataFromCache:NO completionHandler:^(NSError *error){
			// Error with loading
			if (error != nil)
			{
				dispatch_async(dispatch_get_main_queue(), ^{
					_storiesUpdatedSoFar++;
					__strong id strongDelegate = self.delegate;
					[strongDelegate storyUpdaterEncounteredError:[error errorByAddingUserInfoKeysAndValues:@{ @"StoryListEntry" : entry }]];
					[strongDelegate storyUpdaterFinishedStory:entry];
				});
				return;
			}
			
			if (!onlyIfNeeded || (entry.wordCountChangedSinceLastSend || entry.chapterCountChangedSinceLastSend))
			{
				// Load the chapters
				BOOL useCache = !(entry.wordCountChangedSinceLastSend && !entry.chapterCountChangedSinceLastSend) && onlyIfNeeded;
				
				NSError *error = nil;
				BOOL couldLoadChapters = [entry.overview loadChapterDataFromCache:useCache error:&error];
				
				// Could not load them.
				if (!couldLoadChapters)
				{
					dispatch_async(dispatch_get_main_queue(), ^{
						_storiesUpdatedSoFar++;
						__strong id strongDelegate = self.delegate;
						[entry loadErrorImage];
						[strongDelegate storyUpdaterEncounteredError:[error errorByAddingUserInfoKeysAndValues:@{ @"StoryListEntry" : entry }]];
						[strongDelegate storyUpdaterFinishedStory:entry];
					});
					return;
				}
				
				StoryRenderer *renderer = [[StoryRenderer alloc] initWithStoryOverview:entry.overview];
				NSError *mailError = nil;
				BOOL success = [self.sender sendStory:renderer error:&mailError];
				
				if (success)
				{
					entry.wordCountChangedSinceLastSend = NO;
					entry.chapterCountChangedSinceLastSend = NO;
				}
				
				dispatch_async(dispatch_get_main_queue(), ^{
					_storiesUpdatedSoFar++;
					__strong id strongDelegate = self.delegate;
					if (!success)
					{
						[entry loadErrorImage];
						[strongDelegate storyUpdaterEncounteredError:[mailError errorByAddingUserInfoKeysAndValues:@{ @"StoryListEntry" : entry }]];
					}
					[strongDelegate storyUpdaterFinishedStory:entry];
				});
			}
			else
				dispatch_async(dispatch_get_main_queue(), ^{
					_storiesUpdatedSoFar++;
					__strong id strongDelegate = self.delegate;
					[strongDelegate storyUpdaterFinishedStory:entry];
				});
		}];
	}

}

- (void)update;
{
	[self updateStories:[self valueForKeyPath:@"list.stories"] onlyIfNeeded:YES];
}

- (void)forceUpdate:(NSArray *)forceStories;
{
	[self updateStories:forceStories onlyIfNeeded:NO];
}

- (BOOL)isUpdating
{
	return self.storiesToUpdate != self.storiesUpdatedSoFar;
}

@end
