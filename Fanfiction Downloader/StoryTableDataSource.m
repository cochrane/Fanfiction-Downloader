//
//  StoryTableDataSource.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "StoryTableDataSource.h"

#import "StoryList.h"
#import "StoryOverview.h"

@implementation StoryTableDataSource

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
	NSPasteboard *pboard = info.draggingPasteboard;
	
	if ([[pboard types] containsObject:(id) kUTTypeURL])
	{
		NSURL *url = [NSURL URLFromPasteboard:pboard];
		
		if ([StoryOverview URLisValidForStory:url errorDescription:NULL])
		{
			if (dropOperation == NSTableViewDropOn)
				[self.tableView setDropRow:row dropOperation:NSTableViewDropAbove];
			
			return NSDragOperationCopy;
		}
	}
	
	return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
	NSPasteboard *pboard = info.draggingPasteboard;
	
	if ([[pboard types] containsObject:(id) kUTTypeURL])
	{
		NSURL *url = [NSURL URLFromPasteboard:pboard];
		
		if (![StoryOverview URLisValidAndExistsForStory:url errorDescription:NULL]) return NO;
		
		NSUInteger storyID = [StoryOverview storyIDFromURL:url];
		
		[self.storyList addStoryIfNotExists:storyID atIndex:row errorHandler:^(NSError *error){
			[NSApp presentError:error];
		}];
		
		return YES;
	}
	
	return NO;
}

- (void)setTableView:(NSTableView *)view
{
	_tableView = view;
	_tableView.dataSource = self;
	[_tableView registerForDraggedTypes:@[ NSURLPboardType ]];
}

@end
