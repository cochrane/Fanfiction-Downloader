//
//  AddStoryViewController.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AddStorySheetController : NSWindowController

+ (id)runInWindow:(NSWindow *)window completionHandler:(void (^)(BOOL haveStory, NSUInteger storyID))handler;

@property (assign) IBOutlet NSTextField *urlField;

- (IBAction)add:(id)sender;
- (IBAction)cancel:(id)sender;

@end
