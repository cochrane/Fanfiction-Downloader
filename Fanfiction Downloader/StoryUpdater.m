//
//  StoryUpdater.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "StoryUpdater.h"

#import "StoryList.h"
#import "StoryListEntry.h"
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
		[entry loadOverviewFromCache:NO completionHandler:^(StoryOverview *overview, NSError *error){
			// Error with loading
			if (overview == nil)
			{
				dispatch_async(dispatch_get_main_queue(), ^{
					_storiesUpdatedSoFar++;
					__strong id strongDelegate = self.delegate;
					[strongDelegate storyUpdaterEncounteredError:error];
					[strongDelegate storyUpdaterFinishedStory:entry];
				});
				return;
			}
			
			if (!onlyIfNeeded || (entry.wordCountChangedSinceLastSend || entry.chapterCountChangedSinceLastSend))
			{
				// Load the chapters
				BOOL useCache = !(entry.wordCountChangedSinceLastSend && !entry.chapterCountChangedSinceLastSend) && onlyIfNeeded;
				
				NSError *error = nil;
				NSArray *chapters = [entry loadChaptersFromCache:useCache error:&error];
				
				// Could not load them.
				if (chapters == nil)
				{
					dispatch_async(dispatch_get_main_queue(), ^{
						_storiesUpdatedSoFar++;
						__strong id strongDelegate = self.delegate;
						[strongDelegate storyUpdaterEncounteredError:error];
						[strongDelegate storyUpdaterFinishedStory:entry];
					});
					return;
				}
				
				StoryRenderer *renderer = [[StoryRenderer alloc] initWithStoryOverview:overview chapters:chapters];
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
					if (!success)[strongDelegate storyUpdaterEncounteredError:error];
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
