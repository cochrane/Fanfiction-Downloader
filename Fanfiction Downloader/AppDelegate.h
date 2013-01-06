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
@property (assign) IBOutlet NSArrayController *storyListController;

@property (nonatomic, retain) StoryList *storyList;
@property (nonatomic, retain) MainWindowController *mainWindowController;

- (IBAction)add:(id)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)resend:(id)sender;
- (IBAction)showSettings:(id)sender;
- (IBAction)importFromCryzedLemon:(id)sender;
- (IBAction)showWindow:(id)sender;

// For localization. Due to the way the IB handles accessibility strings, it is
// not possible to read them later, so the normal approach to localize items via
// strings fails for them. To avoid having multible .xibs, one per language, I'm
// setting the description programmatically instead. Slightly more work, but not
// that much.

@property (retain, nonatomic) IBOutlet NSButton *addButton;
@property (retain, nonatomic) IBOutlet NSButton *updateButton;
@property (retain, nonatomic) IBOutlet NSButton *removeButton;

- (BOOL)openNewURL:(NSURL *)url error:(NSError *__autoreleasing*)error;
- (void)changeToURL:(NSURL *)url;
- (void)changeToDefaultURL;
- (void)changeToStoredURL;

@end
