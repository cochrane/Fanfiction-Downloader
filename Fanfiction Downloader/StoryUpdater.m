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

@implementation StoryUpdater

- (void)update;
{
	_storiesToUpdate = self.list.countOfStories;
	_storiesUpdatedSoFar = 0;
	
	for (NSUInteger i = 0; i < self.list.countOfStories; i++)
	{
		StoryListEntry *entry = [self.list objectInStoriesAtIndex:i];
		
		[entry loadOverviewFromCache:NO completionHandler:^(StoryOverview *overview, NSError *error){
			// Error with loading
			if (overview == nil)
			{
				dispatch_async(dispatch_get_main_queue(), ^{
					_storiesUpdatedSoFar++;
					[self.delegate storyUpdaterEncounteredError:error];
					[self.delegate storyUpdaterFinishedStory:entry];
				});
				return;
			}
			
			if (entry.wordCountChangedSinceLastSend && entry.chapterCountChangedSinceLastSend)
			{
				// Load the chapters
				BOOL useCache = !(entry.wordCountChangedSinceLastSend && !entry.chapterCountChangedSinceLastSend);
				
				NSError *error = nil;
				NSArray *chapters = [entry loadChaptersFromCache:useCache error:&error];
				
				// Could not load them.
				if (chapters == nil)
				{
					dispatch_async(dispatch_get_main_queue(), ^{
						_storiesUpdatedSoFar++;
						[self.delegate storyUpdaterEncounteredError:error];
						[self.delegate storyUpdaterFinishedStory:entry];
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
					if (!success) [self.delegate storyUpdaterEncounteredError:mailError];
					[self.delegate storyUpdaterFinishedStory:entry];
				});
			}
			else
				dispatch_async(dispatch_get_main_queue(), ^{
					_storiesUpdatedSoFar++;
					[self.delegate storyUpdaterFinishedStory:entry];
				});
		}];
	}
}

- (BOOL)isUpdating
{
	return self.storiesToUpdate != self.storiesUpdatedSoFar;
}

@end
