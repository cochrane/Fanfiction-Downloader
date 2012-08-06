//
//  UpdateProgressWindowController.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 06.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "StoryUpdater.h"

@interface UpdateProgressWindowController : NSWindowController <StoryUpdaterDelegate, NSWindowDelegate>

+ (id)runInWindow:(NSWindow *)window withUpdater:(StoryUpdater *)updater;

@property (nonatomic, retain) StoryUpdater *updater;

@property (nonatomic, weak) IBOutlet NSProgressIndicator *progress;
@property (nonatomic, weak) IBOutlet NSTextField *statusText;

@end
