//
//  ErrorTableCellView.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 19.02.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "ErrorTableCellView.h"

#import "StoryListEntry.h"

@implementation ErrorTableCellView

- (void)setObjectValue:(id)objectValue;
{
	NSAssert(objectValue == nil || [objectValue isKindOfClass:[NSError class]], @"object values for error table cell view must be errors!");
	
	[super setObjectValue:objectValue];
	NSError *error = (NSError *)objectValue;
	
	StoryListEntry *entry = [error.userInfo objectForKey:@"StoryListEntry"];
	
	self.storyNameField.stringValue = entry.localizedDescription;
	self.descriptionField.stringValue = error.localizedDescription;
	self.recoverySuggestionField.stringValue = error.localizedRecoverySuggestion;
}

@end
