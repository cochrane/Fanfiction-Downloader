//
//  NSError+AddKey.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 19.02.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (AddKey)

- (NSError *)errorByAddingUserInfoKeysAndValues:(NSDictionary *)newKeysAndValues;

@end
