//
//  MockURLProtocol.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 11.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MockURLProtocol : NSURLProtocol

+ (void)clearMockData;
+ (void)setData:(NSData *)data forURL:(NSURL *)url;

@end
