//
//  UpdateProgressWindowController.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 06.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SheetController.h"
#import "StoryUpdater.h"

@interface UpdateProgressWindowController : SheetController <StoryUpdaterDelegate, NSWindowDelegate>

@property (nonatomic, retain) StoryUpdater *updater;

@property (nonatomic, weak) IBOutlet NSProgressIndicator *progress;
@property (nonatomic, weak) IBOutlet NSTextField *statusText;

@end
