//
//  FileTemplate.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 05.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileTemplate : NSObject

- (id)initWithTemplateString:(NSString *)template startMarker:(NSString *)startMarker endMarker:(NSString *)endMarker;

- (NSString *)instantiateWithValues:(NSDictionary *)values;

@end
