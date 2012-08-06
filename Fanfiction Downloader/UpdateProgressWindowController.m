//
//  UpdateProgressWindowController.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 06.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "UpdateProgressWindowController.h"

#import "StoryList.h"
#import "StoryListEntry.h"

@interface UpdateProgressWindowController ()

@property NSMutableArray *errors;

@end

@implementation UpdateProgressWindowController

+ (id)runInWindow:(NSWindow *)window withUpdater:(StoryUpdater *)updater;
{
	UpdateProgressWindowController *instance = [[self alloc] init];
	
	instance.updater = updater;
	instance.updater.delegate = instance;
	
	[NSApp beginSheet:instance.window modalForWindow:window modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
	
	CFRetain((__bridge void *) instance);
	
	return instance;
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
			[NSApp endSheet:self.window];
			[self.window orderOut:self];
			
			if (self.errors.count == 1)
			{
				[NSApp presentError:self.errors.lastObject];
			}
			else if (self.errors.count > 1)
			{
				NSAlert *alert = [[NSAlert alloc] init];
				alert.messageText = NSLocalizedString(@"There were multiple errors", @"more than one error during update");
				alert.informativeText = NSLocalizedString(@"Check your network connection and/or try again. I don't know.", @"more than one error during update");
				[alert addButtonWithTitle:NSLocalizedString(@"OK", @"Alert button title")];
				[alert runModal];
			}
			
			CFRelease((__bridge void *) self);
		});
	}
}

@end
