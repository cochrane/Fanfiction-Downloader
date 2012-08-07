//
//  Settings.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class EmailSender;

@interface Settings : NSWindowController <NSWindowDelegate>

- (id)init;

@property (retain, nonatomic) IBOutlet NSUserDefaultsController *defaultsController;

@end
