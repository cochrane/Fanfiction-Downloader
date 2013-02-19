//
//  MainWindowController.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 08.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "MainWindowController.h"

#import "SheetController.h"

@interface MainWindowController ()

- (BOOL)hasSheet;
- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

@property (retain, nonatomic) SheetController *sheetToRestoreAfterError;

@end

@implementation MainWindowController

- (id)initWithWindow:(NSWindow *)window
{
    if (!(self = [super initWithWindow:window])) return nil;
	
	self.shouldCascadeWindows = NO;
	self.window.delegate = self;
    
    return self;
}

- (void)setCurrentSheet:(SheetController *)currentSheet
{
	if (_currentSheet)
		_currentSheet.parent = nil;
	
	_currentSheet = currentSheet;
	_currentSheet.parent = self;
}

- (BOOL)hasSheet
{
	return self.window.attachedSheet != nil;
}

- (void)startSheet:(SheetController *)sheet
{
	if ([self hasSheet]) return;
	
	self.currentSheet = sheet;
	
	[[NSApplication sharedApplication] beginSheet:sheet.window modalForWindow:self.window modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
}

- (void)endSheet
{
	[[NSApplication sharedApplication] endSheet:self.currentSheet.window];
	[self.currentSheet.window orderOut:self];
	
	self.currentSheet = nil;
}

- (void)showError:(NSError *)error resumeAfter:(BOOL)resume;
{
	[self showAlert:[NSAlert alertWithError:error] resumeAfter:resume];
}
- (void)showAlert:(NSAlert *)alert resumeAfter:(BOOL)resume;
{
	if ([self hasSheet] && self.currentSheet == nil)
	{
		NSLog(@"Cannot show error due to non-managed sheet active.");
		return;
	}
	
	if (resume)
		self.sheetToRestoreAfterError = self.currentSheet;
	if (self.currentSheet != nil)
		[self endSheet];
	
	[alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}
- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
	if (self.sheetToRestoreAfterError != nil)
		[self startSheet:self.sheetToRestoreAfterError];
	self.sheetToRestoreAfterError = nil;
}

#pragma mark - Window delegate

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
	return self.undoManager;
}

@end
