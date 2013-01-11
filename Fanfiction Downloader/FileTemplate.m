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

- (id)initWithTemplateScanner:(NSScanner *)scanner startMarker:(NSString *)startMarker endMarker:(NSString *)endMarker;

@end

@implementation FileTemplate

- (id)initWithTemplateString:(NSString *)template startMarker:(NSString *)startMarker endMarker:(NSString *)endMarker;
{
	NSScanner *scanner = [NSScanner scannerWithString:template];
	scanner.charactersToBeSkipped = [NSCharacterSet characterSetWithCharactersInString:@""];
	
	return [self initWithTemplateScanner:scanner startMarker:startMarker endMarker:endMarker];
}

- (id)initWithTemplateScanner:(NSScanner *)scanner startMarker:(NSString *)startMarker endMarker:(NSString *)endMarker;
{
	if (!(self = [super init])) return nil;
	
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
		
		if ([marker isEqual:@"endif"])
			[components addObject:[[FileTemplateEndIfMarker alloc] init]];
		else if ([marker hasPrefix:@"ifdef "])
			[components addObject:[[FileTemplateIfMarker alloc] initWithProperty:[marker substringFromIndex:[@"ifdef " length]]]];
		else
			[components addObject:[[FileTemplateMarker alloc] initWithName:marker]];
		
		[scanner scanString:endMarker intoString:NULL];
	}
	
	_components = [components copy];
	
	return self;
}

- (NSString *)instantiateWithValues:(NSDictionary *)values;
{
	NSMutableString *result = [NSMutableString string];
	
	for (NSUInteger i = 0; i < self.components.count; i++)
	{
		id component = [self.components objectAtIndex:i];
		
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
		else if ([component isKindOfClass:[FileTemplateIfMarker class]])
		{
			if (![values objectForKey:[component property]])
			{
				NSUInteger ifsEncountered = 1;
				while (ifsEncountered > 0)
				{
					i += 1;
					component = [self.components objectAtIndex:i];
					if ([component isKindOfClass:[FileTemplateIfMarker class]])
						ifsEncountered += 1;
					else if ([component isKindOfClass:[FileTemplateEndIfMarker class]])
						ifsEncountered -= 1;
				}
			}
		}
		else if ([component isKindOfClass:[FileTemplateEndIfMarker class]])
		{
			// Ignore
		}
	}
	
	return result;
}

@end
