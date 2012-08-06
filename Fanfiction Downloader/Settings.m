//
//  Settings.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "Settings.h"

@implementation Settings

- (id)init;
{
	if (!(self = [super initWithWindowNibName:@"Settings" owner:self])) return nil;
	
	
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
	self.window.delegate = self;
}

- (void)windowWillClose:(NSNotification *)notification
{
	[self.defaultsController commitEditing];
}

@end
