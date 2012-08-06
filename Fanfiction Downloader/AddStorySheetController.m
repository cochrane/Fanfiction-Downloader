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
@property (retain, nonatomic) NSWindow *parentWindow;

- (void)showError:(NSError *)error;

@end

@implementation AddStorySheetController


+ (id)runInWindow:(NSWindow *)window completionHandler:(void (^)(BOOL haveStory, NSUInteger storyID))handler;
{
	AddStorySheetController *instance = [[self alloc] initWithWindowNibName:@"AddStoryView"];
	instance.completionHandler = handler;
	instance.parentWindow = window;
	
	[NSApp beginSheet:instance.window modalForWindow:window modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
	
	CFRetain((__bridge CFTypeRef) instance);
	
	return instance;
}

- (void)add:(id)sender
{
	NSURL *url = [NSURL URLWithString:[self.urlField stringValue]];
	
	NSError *error = nil;
	
	if (![StoryOverview URLisValidAndExistsForStory:url errorDescription:&error])
	{
		[self showError:error];
		return;
	}
	
	NSUInteger storyID = [StoryOverview storyIDFromURL:url];
	
	[NSApp endSheet:self.window];
	[self.window orderOut:self];
	self.completionHandler(YES, storyID);
	
	CFRelease((__bridge CFTypeRef) self);
}

- (void)cancel:(id)sender
{
	[NSApp endSheet:self.window];
	[self.window orderOut:self];
	self.completionHandler(NO, 0);
	
	CFRelease((__bridge CFTypeRef) self);
}

- (void)showError:(NSError *)error;
{
	[NSApp endSheet:self.window];
	[self.window orderOut:self];
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.parentWindow presentError:error];
		[NSApp beginSheet:self.window modalForWindow:self.parentWindow modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
	});
}

@end
