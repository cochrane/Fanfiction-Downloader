//
//  EmailSender.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 05.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "EmailSender.h"

#import "Mail.h"
#import "StoryRenderer.h"

static NSString *mailBundleIdentifier = @"com.apple.mail";
static NSString *mailOutgoingMessageClass = @"outgoing message";
static NSString *mailToRecipientClass = @"to recipient";
static NSString *mailAttachmentClass = @"attachment";

@implementation EmailSender

- (BOOL)sendStory:(StoryRenderer *)renderedStory error:(NSError * __autoreleasing *)error;
{
	MailApplication *mail = [SBApplication applicationWithBundleIdentifier:mailBundleIdentifier];
	mail.delegate = self;
	
	// Create message
	MailOutgoingMessage *message = [[[mail classForScriptingClass:mailOutgoingMessageClass] alloc] initWithProperties:@{ @"subject" : renderedStory.title, @"content" : renderedStory.summary }];
	if (!message)
	{
		if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:12 userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Could not create new message in Mail", @"MailOutgoingMessage failed") }];
		return NO;
	}
	
	[[mail outgoingMessages] addObject:message];
	message.sender = self.senderAddress;
	
	// Create recipient
	MailToRecipient *recipient = [[[mail classForScriptingClass:mailToRecipientClass] alloc] initWithProperties:@{ @"address" : self.recipientAddress }];
	if (!recipient)
	{
		if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:12 userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Could not create new recipient in Mail", @"MailToRecipient failed") }];
		return NO;
	}
	[[message recipients] addObject:recipient];
	
	// Write rendered code to temp file
	NSURL *overallTempDir = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
	NSURL *appTempDir = [overallTempDir URLByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier] isDirectory:YES];
	[[NSFileManager defaultManager] createDirectoryAtURL:appTempDir withIntermediateDirectories:YES attributes:nil error:NULL];
	
	NSURL *tempURL = [[appTempDir URLByAppendingPathComponent:renderedStory.title] URLByAppendingPathExtension:@"html"];
	[renderedStory.renderedStory writeToURL:tempURL atomically:NO];
	
	// Add this temp file as attachment
	MailAttachment *attachment = [[[mail classForScriptingClass:mailAttachmentClass] alloc] initWithProperties:@{ @"fileName" : tempURL }];
	if (!recipient)
	{
		if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:12 userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Could not create attachment in Mail", @"MailAttachment failed") }];
		[[NSFileManager defaultManager] removeItemAtURL:tempURL error:NULL];
		return NO;
	}
	[[message.content attachments] addObject:attachment];
	
	// send
	BOOL couldSend = [message send];
	if (!couldSend)
	{
		if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:12 userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Could not send the email", @"message send failed") }];
		[[NSFileManager defaultManager] removeItemAtURL:tempURL error:NULL];
		return NO;
	}
	
	// Cleanup the temp file
	[[NSFileManager defaultManager] removeItemAtURL:tempURL error:NULL];
	
	return couldSend;
}

- (id)eventDidFail:(const AppleEvent *)event withError:(NSError *)error;
{
	NSLog(@"An AppleEvent failed: %@", error);
	return nil;
}

@end
