//
//  NSArray+Map.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 06.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Map)

- (NSArray *)map:(id (^)(id))block;
- (NSMutableArray *)mapMutable:(id (^)(id))block;

@end
