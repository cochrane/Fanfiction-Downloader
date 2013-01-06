//
//  Settings.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AppDelegate;
@class EmailSender;

@interface Settings : NSWindowController <NSWindowDelegate>

- (id)init;

@property (weak) AppDelegate *appDelegate;

@property (retain, nonatomic) IBOutlet NSUserDefaultsController *defaultsController;

@property (retain, nonatomic) IBOutlet NSPopUpButton *storyListPopup;

- (IBAction)createANewFile:(id)sender;
- (IBAction)chooseAnExistingFile:(id)sender;
- (IBAction)chooseDefault:(id)sender;
- (IBAction)selectExistingPath:(id)sender;

@end
