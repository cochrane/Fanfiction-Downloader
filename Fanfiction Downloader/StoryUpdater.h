//
//  StoryUpdater.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class EmailSender;
@class StoryList;
@class StoryListEntry;

@protocol StoryUpdaterDelegate <NSObject>

- (void)storyUpdaterEncounteredError:(NSError *)error;
- (void)storyUpdaterFinishedStory:(StoryListEntry *)story;

@end

@interface StoryUpdater : NSObject

@property (retain, nonatomic) StoryList *list;
@property (weak, nonatomic) id<StoryUpdaterDelegate> delegate;
@property (retain, nonatomic) EmailSender *sender;

@property (readonly, assign, nonatomic) NSUInteger storiesToUpdate;
@property (readonly, assign, nonatomic) NSUInteger storiesUpdatedSoFar;

@property (readonly, assign, nonatomic) BOOL isUpdating;

- (void)update;
- (void)forceUpdate:(NSArray *)forceStories;

@end
