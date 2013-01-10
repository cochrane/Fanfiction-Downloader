//
//  AppDelegate.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "AppDelegate.h"

#import "AddStorySheetController.h"
#import "EmailSender.h"
#import "MainWindowController.h"
#import "LemonImporter.h"
#import "Settings.h"
#import "StoryList.h"
#import "StoryUpdater.h"
#import "StoryTableDataSource.h"
#import "UpdateProgressWindowController.h"
#import "UserDefaultsKeys.h"

static NSString *storyListSuiteName = @"storylist";

@interface AppDelegate ()

@property (nonatomic, retain) NSUserDefaults *normalDefaults;
@property (nonatomic, retain) StoryTableDataSource *tableDataSource;
@property (nonatomic, retain) StoryUpdater *updater;
@property (nonatomic, retain) Settings *settingsController;
@property (nonatomic, retain) EmailSender *sender;

@property (nonatomic, readonly, retain) NSURL *defaultStoryListURL;
@property (nonatomic, readonly, retain) NSURL *storyListURL;

- (BOOL)openUpdateControllerIfPossible;

@end

@implementation AppDelegate

#pragma mark - App Delegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	self.mainWindowController = [[MainWindowController alloc] initWithWindow:self.window];
	
	self.normalDefaults = [NSUserDefaults standardUserDefaults];
	
	NSURL *storyListURL = self.storyListURL;
	StoryList *list = [[StoryList alloc] initWithContentsOfURL:storyListURL error:NULL];
	
	if (!list)
	{
		id plist = [self.normalDefaults arrayForKey:DefaultsStoryListKey];
		list = [[StoryList alloc] initWithPropertyList:plist];
		list.propertyListURL = storyListURL;
		[list writeToFileWithError:NULL];
	}
	self.storyList = list;
	
	self.tableDataSource = [[StoryTableDataSource alloc] init];
	self.tableDataSource.storyList = self.storyList;
	self.tableDataSource.tableView = self.tableView;
	
	self.settingsController = [[Settings alloc] init];
	self.settingsController.appDelegate = self;
	if ([self.normalDefaults stringForKey:@"sender"] == nil || [[self.normalDefaults stringForKey:@"sender"] isEqual:@""] || [self.normalDefaults stringForKey:@"recipient"] == nil || [[self.normalDefaults stringForKey:@"recipient"] isEqual:@""])
		[self.settingsController showWindow:self];
	
	self.sender = [[EmailSender alloc] init];
	self.updater = [[StoryUpdater alloc] init];
	self.updater.sender = self.sender;
	self.updater.list = self.storyList;
	
	// Localize accessibility attributes
	// Needs to be done here, since IB sets the override values and they can't be retrieved from code.
	[self.addButton accessibilitySetOverrideValue:NSLocalizedString(@"Add story…", @"Add button accessibility description") forAttribute:NSAccessibilityDescriptionAttribute];
	[self.updateButton accessibilitySetOverrideValue:NSLocalizedString(@"Update…", @"Update button accessibility description") forAttribute:NSAccessibilityDescriptionAttribute];
	[self.removeButton accessibilitySetOverrideValue:NSLocalizedString(@"Remove story…", @"Remove button accessibility description") forAttribute:NSAccessibilityDescriptionAttribute];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[self.storyList writeToFileWithError:NULL];
}

#pragma mark - Changes from the settings controller

- (BOOL)openNewURL:(NSURL *)url error:(NSError *__autoreleasing*)error;
{
	StoryList *newList = [[StoryList alloc] initWithContentsOfURL:url error:error];
	if (!newList) return NO;
	
	self.storyList = newList;
	self.tableDataSource.storyList = self.storyList;
	self.updater.list = self.storyList;
	
	return YES;
}

- (void)changeToURL:(NSURL *)url;
{
	self.storyList.propertyListURL = url;
	[self.storyList writeToFileWithError:NULL];
}

- (void)changeToDefaultURL;
{
	[self changeToURL:self.defaultStoryListURL];
}

- (void)changeToStoredURL;
{
	[self changeToURL:self.storyListURL];
}

#pragma mark - Actions

- (void)deleteBackward:(id)sender
{
	NSLog(@"Delete backward");
}

- (void)deleteForward:(id)sender
{
	NSLog(@"Delete forward");
}

- (void)add:(id)sender
{
	AddStorySheetController *controller = [[AddStorySheetController alloc] init];
	
	[controller startWithParent:self.mainWindowController completionHandler:^(BOOL haveStory, StoryID *newStoryID){
		if (!haveStory) return;
		
		[self.storyList addStoryIfNotExists:newStoryID errorHandler:^(NSError *error){
			[self.window presentError:error];
		}];
	}];
}

- (void)refresh:(id)sender
{
	[self.storyList writeToFileWithError:NULL];
	
	if ([self openUpdateControllerIfPossible])
		[self.updater update];
	
	[self.storyList writeToFileWithError:NULL];
}

- (void)resend:(id)sender
{
	NSArray *selectedStories = [self.storyListController valueForKeyPath:@"selectedObjects.self"];
	if ([selectedStories count] == 0)
	{
		NSBeep();
		return;
	}
	
	if ([self openUpdateControllerIfPossible])
		[self.updater forceUpdate:selectedStories];
}

- (IBAction)showSettings:(id)sender;
{
	[self.settingsController showWindow:sender];
}
- (IBAction)showWindow:(id)sender;
{
	[self.mainWindowController showWindow:sender];
}

- (IBAction)importFromCryzedLemon:(id)sender;
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	panel.canChooseDirectories = NO;
	panel.canChooseFiles = YES;
	panel.allowsMultipleSelection = NO;
	panel.allowedFileTypes = @[ (id) @"com.microsoft.ini" ];
	
	[panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
		if (result != NSOKButton) return;
		
		NSURL *url = panel.URL;
		if (![url.pathComponents.lastObject isEqual:@"stories.ini"])
		{
			NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:78 userInfo:@{
						   NSLocalizedDescriptionKey : NSLocalizedString(@"Not a stories.ini file", @"URL does not end with stories.ini"),
					NSLocalizedFailureReasonErrorKey : NSLocalizedString(@"Select a stories.ini file.", @"Do it")}];
			[self.window presentError:error];
			return;
		}
		
		NSError *importError = nil;
		LemonImporter *importer = [[LemonImporter alloc] init];
		if (![importer importStoriesFromFile:url intoList:self.storyList error:&importError])
			[self.window presentError:importError];
	}];
}

#pragma mark - Private methods

- (BOOL)openUpdateControllerIfPossible;
{
	// Don't update twice at once
	if (self.updater.isUpdating)
	{
		NSBeep();
		return NO;
	}
	
	// Don't update if there are no stories
	if (self.storyList.countOfStories == 0)
	{
		NSBeep();
		return NO;
	}
	
	// Check whether sender and recipient have been set correctly.
	if ([self.normalDefaults stringForKey:@"sender"] == nil || [[self.normalDefaults stringForKey:@"sender"] isEqual:@""] || [self.normalDefaults stringForKey:@"recipient"] == nil || [[self.normalDefaults stringForKey:@"recipient"] isEqual:@""])
	{
		[self.settingsController showWindow:self];
		return NO;
	}
	
	self.sender.recipientAddress = [self.normalDefaults stringForKey:@"recipient"];
	self.sender.senderAddress = [self.normalDefaults stringForKey:@"sender"];
	
	UpdateProgressWindowController *controller = [[UpdateProgressWindowController alloc] init];
	
	controller.updater = self.updater;
	
	[controller startWithParent:self.mainWindowController];
	
	return YES;
}

- (NSURL *)defaultStoryListURL
{
	NSURL *applicationSupport = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
	NSURL *myApplicationSupport = [applicationSupport URLByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier] isDirectory:YES];
	[[NSFileManager defaultManager] createDirectoryAtURL:myApplicationSupport withIntermediateDirectories:YES attributes:nil error:NULL];
	return [myApplicationSupport URLByAppendingPathComponent:@"Stories.plist"];
}

- (NSURL *)storyListURL
{	
	if (![[NSUserDefaults standardUserDefaults] boolForKey:DefaultsUseExternalStoreKey])
		return self.defaultStoryListURL;
	
	NSData *bookmark = [[NSUserDefaults standardUserDefaults] objectForKey:DefaultsExternalStoreBookmarkKey];
	if (!bookmark) return self.defaultStoryListURL;
	
	BOOL isStale = NO;
	NSError *error = nil;
	NSURL *url = [NSURL URLByResolvingBookmarkData:bookmark options:0 relativeToURL:nil bookmarkDataIsStale:&isStale error:&error];
	if (!url) return self.defaultStoryListURL;
	
	return url;
}

@end
