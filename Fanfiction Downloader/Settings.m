//
//  Settings.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "Settings.h"

#import "AppDelegate.h"
#import "UserDefaultsKeys.h"

@implementation Settings

- (id)init;
{
	if (!(self = [super initWithWindowNibName:@"Settings" owner:self])) return nil;
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{
									   DefaultsUseExternalStoreKey : @(NO)
	 }];
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
	self.window.delegate = self;
	
	// Set file name and icon for the selected file.
	NSData *bookmark = [[NSUserDefaults standardUserDefaults] objectForKey:DefaultsExternalStoreBookmarkKey];
	NSMenuItem *locationMarkerItem = [self.storyListPopup itemAtIndex:[self.storyListPopup indexOfItemWithTag:2]];
	if (!bookmark)
	{
		locationMarkerItem.hidden = YES;
		[self.storyListPopup selectItemAtIndex:0];
	}
	else
	{
		BOOL isStale = NO;
		NSError *error = nil;
		NSURL *url = [NSURL URLByResolvingBookmarkData:bookmark options:0 relativeToURL:nil bookmarkDataIsStale:&isStale error:&error];
		
		if (!url)
		{
			locationMarkerItem.hidden = YES;
			[self.storyListPopup selectItemAtIndex:0];
			[[NSUserDefaults standardUserDefaults] setBool:NO forKey:DefaultsUseExternalStoreKey];
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:DefaultsExternalStoreBookmarkKey];
			
			[self presentError:error modalForWindow:self.window delegate:nil didPresentSelector:NULL contextInfo:NULL];
		}
		else
		{
			locationMarkerItem.title = url.lastPathComponent;
			
			if ([[NSUserDefaults standardUserDefaults] boolForKey:DefaultsUseExternalStoreKey])
				[self.storyListPopup selectItemWithTag:2];
			else
				[self.storyListPopup selectItemAtIndex:0];
			
			NSError *error;
			NSDictionary *values = [url resourceValuesForKeys:@[ NSURLEffectiveIconKey, NSURLLocalizedNameKey ] error:&error];
			
			if (!values)
			{
				[self presentError:error modalForWindow:self.window delegate:nil didPresentSelector:NULL contextInfo:NULL];
			}
			else
			{
				locationMarkerItem.hidden = NO;
				locationMarkerItem.image = [values objectForKey:NSURLEffectiveIconKey];
				locationMarkerItem.title = [values objectForKey:NSURLLocalizedNameKey];
			}
		}
	}
}

- (void)windowWillClose:(NSNotification *)notification
{
	[self.defaultsController commitEditing];
}

- (void)choosePath:(id)sender
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	savePanel.allowedFileTypes = @[ @"com.apple.property-list" ];
	savePanel.allowsOtherFileTypes = YES;
	savePanel.canCreateDirectories = YES;
	savePanel.title = NSLocalizedString(@"Choose a new location for the story list", @"Story list save panel");
	savePanel.prompt = NSLocalizedString(@"Choose", @"Story list save panel");
	savePanel.nameFieldStringValue = NSLocalizedString(@"Story List", @"Story list save panel");
	
	[savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
		if (result != NSOKButton) return;
		
		NSMenuItem *locationMarkerItem = [self.storyListPopup itemAtIndex:[self.storyListPopup indexOfItemWithTag:2]];
		locationMarkerItem.hidden = NO;
		locationMarkerItem.title = savePanel.URL.lastPathComponent;
		[self.storyListPopup selectItem:locationMarkerItem];
		
		// Tell app delegate about it.
		AppDelegate *delegate = self.appDelegate;
		[delegate changeToURL:savePanel.URL];
		
		// Store as default
		NSData *data = [savePanel.URL bookmarkDataWithOptions:0 includingResourceValuesForKeys:nil relativeToURL:nil error:NULL];
		[[NSUserDefaults standardUserDefaults] setObject:data forKey:DefaultsExternalStoreBookmarkKey];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:DefaultsUseExternalStoreKey];
		
		// Get localized name and image
		NSDictionary *values = [savePanel.URL resourceValuesForKeys:@[ NSURLEffectiveIconKey, NSURLLocalizedNameKey ] error:NULL];
		if (values)
		{
			locationMarkerItem.image = [values objectForKey:NSURLEffectiveIconKey];
			locationMarkerItem.title = [values objectForKey:NSURLLocalizedNameKey];
		}
	}];
}

- (void)chooseDefault:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:DefaultsUseExternalStoreKey];
	
	// Tell app delegate about it.
	AppDelegate *delegate = self.appDelegate;
	[delegate changeToDefaultURL];
}
- (void)selectExistingPath:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:DefaultsUseExternalStoreKey];
	
	// Tell app delegate about it.
	AppDelegate *delegate = self.appDelegate;
	[delegate changeToStoredURL];
}

@end
