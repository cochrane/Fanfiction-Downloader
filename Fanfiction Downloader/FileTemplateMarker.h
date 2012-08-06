//
//  FileTemplateMarker.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 05.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileTemplateMarker : NSObject

@property (copy, nonatomic, readonly) NSString *name;

- (id)initWithName:(NSString *)name;

@end
