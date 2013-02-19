//
//  NSError+AddKey.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 19.02.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "NSError+AddKey.h"

@implementation NSError (AddKey)

- (NSError *)errorByAddingUserInfoKeysAndValues:(NSDictionary *)newKeysAndValues;
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
	[dict addEntriesFromDictionary:newKeysAndValues];
	
	return [[self class] errorWithDomain:self.domain code:self.code userInfo:dict];
}

@end
