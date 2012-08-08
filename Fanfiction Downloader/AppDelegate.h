//
//  AppDelegate.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MainWindowController;
@class StoryList;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTableView *tableView;

@property (nonatomic, retain) StoryList *storyList;
@property (nonatomic, retain) MainWindowController *mainWindowController;

- (IBAction)add:(id)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)showSettings:(id)sender;
- (IBAction)importFromCryzedLemon:(id)sender;

@end
