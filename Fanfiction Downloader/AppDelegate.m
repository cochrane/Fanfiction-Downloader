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

static NSString *userDefaultsStoryListKey = @"stories";
static NSString *storyListSuiteName = @"storylist";

@interface AppDelegate ()

@property (nonatomic, retain) NSUserDefaults *storyDefaults;
@property (nonatomic, retain) NSUserDefaults *normalDefaults;
@property (nonatomic, retain) StoryTableDataSource *tableDataSource;
@property (nonatomic, retain) StoryUpdater *updater;
@property (nonatomic, retain) Settings *settingsController;
@property (nonatomic, retain) EmailSender *sender;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	self.mainWindowController = [[MainWindowController alloc] initWithWindow:self.window];
	
	NSString *suiteName = [[NSBundle mainBundle].bundleIdentifier stringByAppendingFormat:@".%@", storyListSuiteName];
	
	self.storyDefaults = [[NSUserDefaults alloc] init];
	[self.storyDefaults addSuiteNamed:suiteName];
	
	self.normalDefaults = [NSUserDefaults standardUserDefaults];

	id plist = [self.storyDefaults arrayForKey:userDefaultsStoryListKey];
	
	StoryList *list = [[StoryList alloc] initWithPropertyList:plist];
	
	self.tableDataSource = [[StoryTableDataSource alloc] init];
	self.tableDataSource.storyList = list;
	self.tableDataSource.tableView = self.tableView;
		
	[self setValue:list forKey:@"storyList"];
	
	self.settingsController = [[Settings alloc] init];
	if ([self.normalDefaults stringForKey:@"sender"] == nil || [[self.normalDefaults stringForKey:@"sender"] isEqual:@""] || [self.normalDefaults stringForKey:@"recipient"] == nil || [[self.normalDefaults stringForKey:@"recipient"] isEqual:@""])
		[self.settingsController showWindow:self];
	
	self.sender = [[EmailSender alloc] init];
	self.updater = [[StoryUpdater alloc] init];
	self.updater.sender = self.sender;
	self.updater.list = self.storyList;
}

- (void)deleteBackward:(id)sender
{
	NSLog(@"Delete backward");
}

- (void)deleteForward:(id)sender
{
	NSLog(@"Delete forward");
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[self.storyDefaults setObject:[self.storyList writeToPropertyList] forKey:userDefaultsStoryListKey];
	[self.storyDefaults synchronize];
}

- (void)add:(id)sender
{
	AddStorySheetController *controller = [[AddStorySheetController alloc] init];
	
	[controller startWithParent:self.mainWindowController completionHandler:^(BOOL haveStory, NSUInteger newStoryID){
		if (!haveStory) return;
		
		[self.storyList addStoryIfNotExists:newStoryID errorHandler:^(NSError *error){
			[self.window presentError:error];
		}];
	}];
}

- (void)refresh:(id)sender
{
	// Don't update twice at once
	if (self.updater.isUpdating)
	{
		NSBeep();
		return;
	}
	
	// Don't update if there are no stories
	if (self.storyList.countOfStories == 0)
	{
		NSBeep();
		return;
	}
	
	// Check whether sender and recipient have been set correctly.
	if ([self.normalDefaults stringForKey:@"sender"] == nil || [[self.normalDefaults stringForKey:@"sender"] isEqual:@""] || [self.normalDefaults stringForKey:@"recipient"] == nil || [[self.normalDefaults stringForKey:@"recipient"] isEqual:@""])
	{
		[self.settingsController showWindow:self];
		return;
	}
	
	self.sender.recipientAddress = [self.normalDefaults stringForKey:@"recipient"];
	self.sender.senderAddress = [self.normalDefaults stringForKey:@"sender"];
	
	UpdateProgressWindowController *controller = [[UpdateProgressWindowController alloc] init];
	
	controller.updater = self.updater;
	
	[controller startWithParent:self.mainWindowController];
	
	[self.updater update];
}

- (IBAction)showSettings:(id)sender;
{
	[self.settingsController showWindow:sender];
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

@end
