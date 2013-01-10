//
//  StoryTableDataSource.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "StoryTableDataSource.h"

#import "StoryID.h"
#import "StoryList.h"
#import "StoryOverview.h"

@implementation StoryTableDataSource

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
	_tableView.dataSource = self;
	[_tableView registerForDraggedTypes:@[ NSURLPboardType ]];
}

@end
