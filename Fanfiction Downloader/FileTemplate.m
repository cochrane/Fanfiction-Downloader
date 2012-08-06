//
//  FileTemplate.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 05.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "FileTemplate.h"

#import "FileTemplateMarker.h"

@interface FileTemplate ()

@property (nonatomic, copy, readonly) NSArray *components;

@end

@implementation FileTemplate

- (id)initWithTemplateString:(NSString *)template startMarker:(NSString *)startMarker endMarker:(NSString *)endMarker;
{
	if (!(self = [super init])) return nil;
	
	NSScanner *scanner = [NSScanner scannerWithString:template];
	NSMutableArray *components = [NSMutableArray array];
	while (![scanner isAtEnd])
	{
		NSString *text;
		[scanner scanUpToString:startMarker intoString:&text];
		[components addObject:text];
		if (scanner.isAtEnd) break;
		
		[scanner scanString:startMarker intoString:NULL];
		
		NSString *marker;
		[scanner scanUpToString:endMarker intoString:&marker];
		[components addObject:[[FileTemplateMarker alloc] initWithName:marker]];
		
		[scanner scanString:endMarker intoString:NULL];
	}
	
	_components = components;
	
	return self;
}

- (NSString *)instantiateWithValues:(NSDictionary *)values;
{
	NSMutableString *result = [NSMutableString string];
	
	for (id component in self.components)
	{
		if ([component isKindOfClass:[NSString class]])
			[result appendString:component];
		else if ([component isKindOfClass:[FileTemplateMarker class]])
		{
			NSString *replacement = [values objectForKey:[component name]];
			if (!replacement)
			{
				NSLog(@"No replacement for %@", [component name]);
				replacement = NSLocalizedString(@"Template error: No replacement specified", @"Forgot replacement in a template");
			}
			[result appendString:replacement];
		}
	}
	
	return result;
}

@end
