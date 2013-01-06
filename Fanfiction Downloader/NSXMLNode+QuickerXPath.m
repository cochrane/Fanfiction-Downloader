//
//  NSXMLNode+QuickerXPath.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 04.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "NSXMLNode+QuickerXPath.h"

@implementation NSXMLNode (QuickerXPath)

- (NSXMLNode *)firstNodeForXPath:(NSString *)xpath error:(NSError * __autoreleasing *) error;
{
	NSArray *results = [self nodesForXPath:xpath error:error];
	if ([results count] == 0) return nil;
	
	return [results objectAtIndex:0];
}

- (NSURL *)firstURLForXPath:(NSString *)xpath relativeToBase:(NSURL *)base error:(NSError * __autoreleasing *) error;
{
	NSString *rel = [self firstTextForXPath:xpath error:error];
	if (!rel) return nil;
	return [NSURL URLWithString:rel relativeToURL:base];
}

- (NSString *)firstTextForXPath:(NSString *)xpath error:(NSError * __autoreleasing *) error
{
	return [[self firstNodeForXPath:xpath error:error] stringValue];
}

- (NSString *)allTextForXPath:(NSString *)xpath error:(NSError * __autoreleasing *) error;
{	
	return [[[self nodesForXPath:xpath error:error] valueForKeyPath:@"stringValue"] componentsJoinedByString:@""];
}

@end
