//
//  StoryTableDataSource.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class StoryList;

@interface StoryTableDataSource : NSObject<NSTableViewDataSource>

@property (weak, nonatomic) NSTableView *tableView;

@property (retain, nonatomic) StoryList *storyList;

@end
