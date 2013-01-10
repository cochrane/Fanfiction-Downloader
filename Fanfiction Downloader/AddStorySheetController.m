//
//  AddStoryViewController.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "AddStorySheetController.h"

#import "StoryID.h"

@interface AddStorySheetController ()

@property (copy, nonatomic) void (^completionHandler)(BOOL haveStory, StoryID *storyID);

@end

@implementation AddStorySheetController

- (id)init;
{
	if (!(self = [super initWithWindowNibName:@"AddStoryView"])) return nil;
	
	return self;
}

- (void)startWithParent:(MainWindowController *)parent completionHandler:(void (^)(BOOL haveStory, StoryID *storyID))handler;
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
	
	StoryID *storyID = [[StoryID alloc] initWithURL:url error:&error];
	if (!storyID || ![storyID checkIsReachableWithError:&error])
	{
		[self showError:error resumeAfter:YES];
		return;
	}
	
	self.completionHandler(YES, storyID);
	[self end];
}

- (void)cancel:(id)sender
{
	self.completionHandler(NO, 0);
	[self end];
}

@end
