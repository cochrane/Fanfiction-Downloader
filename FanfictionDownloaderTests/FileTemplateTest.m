//
//  FileTemplateTest.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 11.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "FileTemplateTest.h"

#import "FileTemplate.h"

@implementation FileTemplateTest

- (void)testStandardFileTemplate
{
	NSString *templateText = @"testing {{text1}} more test {{text2}} test again.";
	NSDictionary *replacements = @{
		@"text1" : @"ABC",
		@"text2" : @"DEF"
	};
	
	FileTemplate *template = [[FileTemplate alloc] initWithTemplateString:templateText startMarker:@"{{" endMarker:@"}}"];
	
	NSString *result = [template instantiateWithValues:replacements];
	
	STAssertEqualObjects(result, @"testing ABC more test DEF test again.", @"Incorrect replacement %@", template);
}

@end
