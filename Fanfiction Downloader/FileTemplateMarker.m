//
//  FileTemplateMarker.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 05.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "FileTemplateMarker.h"

@implementation FileTemplateMarker

- (id)initWithName:(NSString *)name
{
	if (!(self = [super init])) return nil;
	
	_name = name;
	
	return self;
}

@end
