//
//  UpdateProgressWindowController.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 06.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "UpdateProgressWindowController.h"

#import "MultipleErrorsViewController.h"
#import "StoryList.h"
#import "StoryListEntry.h"

@interface UpdateProgressWindowController ()

@property (nonatomic) NSMutableArray *errors;
@property (nonatomic) MultipleErrorsViewController *multipleErrorsViewController;

@end

@implementation UpdateProgressWindowController

- (void)setUpdater:(StoryUpdater *)updater
{
	if (_updater)
		_updater.delegate = nil;
	
	_updater = updater;
	_updater.delegate = self;
}

- (id)init
{
    if (!(self = [super initWithWindowNibName:@"UpdateProgressWindowController"]))
		return nil;
	
	self.errors = [NSMutableArray array];
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
	self.window.delegate = self;
	
	self.progress.maxValue = 1.0;
	self.progress.minValue = 0.0;
	self.progress.doubleValue = 0.0;
	self.statusText.stringValue = NSLocalizedString(@"Updating…", @"Update started");
}

- (void)storyUpdaterEncounteredError:(NSError *)error;
{
	[self.errors addObject:error];
}

- (void)storyUpdaterFinishedStory:(StoryListEntry *)story;
{
	self.statusText.stringValue = [NSString stringWithFormat:NSLocalizedString(@"Finished %@.", @"Update progress"), story.title];
	
	self.progress.doubleValue = (double) self.updater.storiesUpdatedSoFar / (double) self.updater.storiesToUpdate;
	
	if (!self.updater.isUpdating)
	{
		double delayInSeconds = 0.2;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		
		dispatch_after(popTime, dispatch_get_main_queue(), ^{
			
			if (self.errors.count == 1)
				[self showError:self.errors.lastObject resumeAfter:NO];
			else if (self.errors.count > 1)
			{
				if (!self.multipleErrorsViewController)
					self.multipleErrorsViewController = [[MultipleErrorsViewController alloc] init];
				
				self.multipleErrorsViewController.errors = self.errors;
				NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"There were multiple errors", @"more than one error during update") defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"Check your network connection and/or try again. I don't know.", @"more than one error during update")];
				alert.accessoryView = self.multipleErrorsViewController.view;
				[self showAlert:alert resumeAfter:NO];
			}
			else
				[self end];
		});
	}
}

@end
