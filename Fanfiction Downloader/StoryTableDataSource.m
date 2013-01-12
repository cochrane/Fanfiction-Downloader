//
//  StoryTableDataSource.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "StoryTableDataSource.h"

#import "AppDelegate.h"
#import "StoryID.h"
#import "StoryList.h"
#import "StoryOverview.h"

@interface StoryTableDataSource ()

- (NSIndexSet *)indicesForRightClick;

@end

@implementation StoryTableDataSource

#pragma mark - Table View Data Source

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
	NSPasteboard *pboard = info.draggingPasteboard;
	
	if (![[pboard types] containsObject:(id) kUTTypeURL])
		return NSDragOperationNone;
	
	NSURL *url = [NSURL URLFromPasteboard:pboard];
	
	StoryID *storyID = [[StoryID alloc] initWithURL:url error:NULL];
	if (!storyID)
		return NSDragOperationNone;
	
	if (dropOperation == NSTableViewDropOn)
		[self.tableView setDropRow:row dropOperation:NSTableViewDropAbove];
		
	return NSDragOperationCopy;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
	NSPasteboard *pboard = info.draggingPasteboard;
	
	if (![[pboard types] containsObject:(id) kUTTypeURL])
		return NO;
	
	NSURL *url = [NSURL URLFromPasteboard:pboard];
	
	StoryID *storyID = [[StoryID alloc] initWithURL:url error:NULL];
	if (!storyID || ![storyID checkIsReachableWithError:NULL])
		return NO;
	
	[self.storyList addStoryIfNotExists:storyID atIndex:row errorHandler:^(NSError *error){
		[NSApp presentError:error];
	}];
	
	return YES;
}

- (void)setTableView:(NSTableView *)view
{
	_tableView = view;
	[_tableView registerForDraggedTypes:@[ NSURLPboardType ]];
}

#pragma mark - Context menu actions

- (IBAction)delete:(id)sender;
{
	NSIndexSet *indices = self.indicesForRightClick;
	
	[[self.storyList mutableArrayValueForKey:@"stories"] removeObjectsAtIndexes:indices];
}
- (IBAction)resend:(id)sender;
{
	NSIndexSet *indices = self.indicesForRightClick;
	NSArray *stories = [[self.storyList valueForKey:@"stories"] objectsAtIndexes:indices];
	[self.appDelegate resendStories:stories];
}
- (IBAction)openInBrowser:(id)sender;
{
	NSIndexSet *indices = self.indicesForRightClick;
	NSArray *storyURLs = [[[self.storyList valueForKey:@"stories"] objectsAtIndexes:indices] valueForKeyPath:@"storyID.overviewURL"];
	
	[[NSWorkspace sharedWorkspace] openURLs:storyURLs withAppBundleIdentifier:nil options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifiers:NULL];
}

#pragma mark - Private methods

- (NSIndexSet *)indicesForRightClick;
{
	NSInteger clicked = self.tableView.clickedRow;
	
	// If click is within selection or completely outside of rows, use
	// selection
	if (clicked == -1)
		return self.tableView.selectedRowIndexes;
	
	if ([self.tableView.selectedRowIndexes containsIndex:clicked])
		return self.tableView.selectedRowIndexes;
	
	// Otherwise, use only clicked row
	return [NSIndexSet indexSetWithIndex:clicked];
}

@end
