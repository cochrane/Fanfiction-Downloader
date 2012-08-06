//
//  StoryChapter.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StoryChapter : NSObject

@property (readonly, assign, nonatomic) NSUInteger number;
@property (readonly, copy, nonatomic) NSString *title;
@property (readonly, copy, nonatomic) NSString *text;

- (id)initWithHTMLData:(NSData *)data error:(NSError * __autoreleasing *)error
;

@end
