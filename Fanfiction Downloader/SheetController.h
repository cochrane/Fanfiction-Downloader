//
//  SheetController.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 08.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MainWindowController;

@interface SheetController : NSWindowController

@property (retain, nonatomic) MainWindowController *parent;

- (void)startWithParent:(MainWindowController *)controller;
- (void)end;

- (void)showError:(NSError *)error resumeAfter:(BOOL)resume;
- (void)showAlert:(NSAlert *)alert resumeAfter:(BOOL)resume;

@end
