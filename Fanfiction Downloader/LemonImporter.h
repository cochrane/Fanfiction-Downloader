//
//  LemonImporter.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 06.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StoryList;

@interface LemonImporter : NSObject

- (BOOL)importStories:(NSString *)iniData intoList:(StoryList *)list error:(NSError * __autoreleasing *)outError;
- (BOOL)importStoriesFromFile:(NSURL *)file intoList:(StoryList *)list error:(NSError * __autoreleasing *)outError;

@end
