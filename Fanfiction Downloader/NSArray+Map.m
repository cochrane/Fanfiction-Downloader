//
//  NSArray+Map.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 06.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "NSArray+Map.h"

@implementation NSArray (Map)

- (NSArray *)map:(id (^)(id))block;
{
	return [[self mapMutable:block] copy];
}
- (NSMutableArray *)mapMutable:(id (^)(id))block;
{
	NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:self.count];
	
	for (id object in self)
	{
		id newObject = block(object);
		[result addObject:newObject ? newObject : [NSNull null]];
	}
	
	return result;
}

@end
