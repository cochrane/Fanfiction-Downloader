//
//  MultipleErrorsViewController.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 19.02.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "MultipleErrorsViewController.h"

@interface MultipleErrorsViewController ()

@end

@implementation MultipleErrorsViewController

- (id)init
{
	return [self initWithNibName:@"MultipleErrorsAccessoryView" bundle:nil];
}

- (void)setErrors:(NSArray *)errors
{
	_errors = errors;
	[self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
	return self.errors.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
	return [self.errors objectAtIndex:row];
}

#pragma mark - Table view delegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
	return [tableView makeViewWithIdentifier:@"ErrorTableCellView" owner:self];
}

@end
