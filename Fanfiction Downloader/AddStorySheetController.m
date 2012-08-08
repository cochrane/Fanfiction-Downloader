//
//  AddStoryViewController.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "AddStorySheetController.h"

#import "StoryOverview.h"

@interface AddStorySheetController ()

@property (copy, nonatomic) void (^completionHandler)(BOOL haveStory, NSUInteger storyID);

@end

@implementation AddStorySheetController

- (id)init;
{
	if (!(self = [super initWithWindowNibName:@"AddStoryView"])) return nil;
	
	return self;
}

- (void)startWithParent:(MainWindowController *)parent completionHandler:(void (^)(BOOL haveStory, NSUInteger storyID))handler;
{
	self.completionHandler = handler;
	
	[self startWithParent:parent];
}

- (void)end
{
	self.completionHandler = nil;
	[super end];
}

- (void)add:(id)sender
{
	NSURL *url = [NSURL URLWithString:[self.urlField stringValue]];
	
	NSError *error = nil;
	
	if (![StoryOverview URLisValidAndExistsForStory:url errorDescription:&error])
	{
		[self showError:error resumeAfter:YES];
		return;
	}
	
	NSUInteger storyID = [StoryOverview storyIDFromURL:url];
	
	self.completionHandler(YES, storyID);
	[self end];
}

- (void)cancel:(id)sender
{
	self.completionHandler(NO, 0);
	[self end];
}

@end
