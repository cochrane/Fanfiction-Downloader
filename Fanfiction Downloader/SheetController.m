//
//  SheetController.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 08.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "SheetController.h"

#import "MainWindowController.h"

@interface SheetController ()

@end

@implementation SheetController

- (void)startWithParent:(MainWindowController *)controller;
{
	// The controller handles all the intricacies and sets
	// itself as our parent.
	[controller startSheet:self];
}

- (void)end
{
	[self.parent endSheet];
}

- (void)showError:(NSError *)error resumeAfter:(BOOL)resume;
{
	[self.parent showError:error resumeAfter:resume];
}

@end
