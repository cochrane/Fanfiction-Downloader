//
//  NSXMLNode+QuickerXPath.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSXMLNode (QuickerXPath)

- (NSString *)firstTextForXPath:(NSString *)xpath error:(NSError * __autoreleasing *) error;
- (NSURL *)firstURLForXPath:(NSString *)xpath relativeToBase:(NSURL *)base error:(NSError * __autoreleasing *) error;

- (NSString *)allTextForXPath:(NSString *)xpath error:(NSError * __autoreleasing *) error;
- (NSXMLNode *)firstNodeForXPath:(NSString *)xpath error:(NSError * __autoreleasing *) error;

- (NSArray *)allTextsForXPath:(NSString *)xpath error:(NSError * __autoreleasing *) error;

@end
