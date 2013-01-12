//
//  StoryTableDataSource.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AppDelegate;
@class StoryList;

@interface StoryTableDataSource : NSObject<NSTableViewDataSource>

@property (assign, nonatomic) IBOutlet AppDelegate *appDelegate;
@property (retain, nonatomic) IBOutlet NSTableView *tableView;

@property (retain, nonatomic) StoryList *storyList;

- (IBAction)delete:(id)sender;
- (IBAction)resend:(id)sender;
- (IBAction)openInBrowser:(id)sender;

@end
