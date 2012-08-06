//
//  EmailSender.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 05.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ScriptingBridge/ScriptingBridge.h>

@class StoryRenderer;

@interface EmailSender : NSObject<SBApplicationDelegate>

@property (nonatomic, copy) NSString *senderAddress;
@property (nonatomic, copy) NSString *recipientAddress;

- (BOOL)sendStory:(StoryRenderer *)renderedStory error:(NSError * __autoreleasing *)error;

@end
