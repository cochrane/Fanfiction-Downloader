//
//  LemonImporter.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 06.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "LemonImporter.h"

#import "StoryList.h"
#import "StoryOverview.h"

@implementation LemonImporter

- (BOOL)importStories:(NSString *)iniData intoList:(StoryList *)list error:(NSError * __autoreleasing *)outError
{
	NSScanner *scanner = [NSScanner scannerWithString:iniData];
	
	while (!scanner.isAtEnd)
	{
		[scanner scanUpToString:@"[" intoString:NULL];
		
		if (![scanner scanString:@"[" intoString:NULL])
			break;
		
		NSString *storyURL;
		[scanner scanUpToString:@"]" intoString:&storyURL];
		[scanner scanString:@"]" intoString:NULL];
		
		NSUInteger storyID = [StoryOverview storyIDFromURL:[NSURL URLWithString:storyURL]];
		if (storyID == 0)
		{
			NSLog(@"Skipped %@", storyURL);
			continue;
		}
		
		[list addStoryIfNotExists:storyID errorHandler:NULL];
	}
	
	return YES;
}

- (BOOL)importStoriesFromFile:(NSURL *)file intoList:(StoryList *)list error:(NSError * __autoreleasing *)outError
{
	NSString *text = [NSString stringWithContentsOfURL:file encoding:NSUTF8StringEncoding error:outError];
	if (!text) return NO;
	
	return [self importStories:text intoList:list error:outError];
}

@end
