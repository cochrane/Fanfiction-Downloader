//
//  StoryID.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 10.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum __StorySite {
	StorySiteFFNet,
	StorySiteAO3
} StorySite;

@interface StoryID : NSObject

@property (nonatomic, readonly) StorySite site;
@property (nonatomic, readonly) NSUInteger siteSpecificID;

- (id)initWithID:(NSUInteger)number site:(StorySite)site;
- (id)initWithURL:(NSURL *)url error:(NSError * __autoreleasing *)error;
- (id)initWithPropertyListRepresentation:(id)plist;

- (BOOL)checkIsReachableWithError:(NSError *__autoreleasing*)error;

@property (nonatomic, readonly) NSURL *overviewURL;
@property (nonatomic, readonly) id propertyListRepresentation;

- (NSUInteger)hash;
- (BOOL)isEqual:(id)object;

@property (nonatomic, readonly) NSString *localizedSiteName;

@end
