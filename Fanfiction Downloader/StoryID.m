//
//  StoryID.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 10.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "StoryID.h"

static NSString *siteIdentifierFF = @"Fanfiction.net";
static NSString *siteIdentifierAO3 = @"ArchiveOfOurOwn.org";
static NSString *KeySite = @"site";
static NSString *KeyNumber = @"number";

@implementation StoryID

- (id)initWithID:(NSUInteger)number site:(StorySite)site;
{
	if (!(self = [super init])) return nil;
	
	_site = site;
	_siteSpecificID = number;
	
	return self;
}

- (id)initWithURL:(NSURL *)storyURL error:(NSError * __autoreleasing *)error;
{
	if (!storyURL)
	{
		if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
						  NSLocalizedDescriptionKey : NSLocalizedString(@"Not a valid URL", @"Cannot create NSURL from entered string"),
			  NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"Please enter a valid web address", @"Works better that way.")}];
		return nil;
	}
	
	NSString *host = storyURL.host;
	if ([host hasSuffix:@"fanfiction.net"])
	{
		NSArray *pathComponents = storyURL.pathComponents;
		if (pathComponents.count < 3 || ![[pathComponents objectAtIndex:1] isEqual:@"s"])
		{
			if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
							  NSLocalizedDescriptionKey : NSLocalizedString(@"Not a story URL", @"Path doesn't start with /s/ or is too short"),
				  NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"This URL does not point to a story.", @"Give correct URL")}];
			return nil;
		}
		
		NSInteger storyID = [[pathComponents objectAtIndex:2] integerValue];
		if (storyID == 0)
		{
			if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
							  NSLocalizedDescriptionKey : NSLocalizedString(@"The URL has no story ID", @"Path[1] is not a number or 0."),
				  NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"This URL does not point to a story.", @"Give correct URL")}];
			return nil;
		}
		
		return [self initWithID:storyID site:StorySiteFFNet];
	}
	else if ([host hasSuffix:@"archiveofourown.org"])
	{		NSArray *pathComponents = storyURL.pathComponents;
		if (pathComponents.count < 3 || ![[pathComponents objectAtIndex:1] isEqual:@"works"])
		{
			if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
							  NSLocalizedDescriptionKey : NSLocalizedString(@"Not a story URL", @"Path doesn't start with /works/ or is too short"),
				  NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"This URL does not point to a story.", @"Give correct URL")}];
			return nil;
		}
		
		NSInteger storyID = [[pathComponents objectAtIndex:2] integerValue];
		if (storyID == 0)
		{
			if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
							  NSLocalizedDescriptionKey : NSLocalizedString(@"The URL has no story ID", @"Path[1] is not a number or 0."),
				  NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"This URL does not point to a story.", @"Give correct URL")}];
			return nil;
		}
		
		return [self initWithID:storyID site:StorySiteAO3];
	}
	else
	{
		if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
						  NSLocalizedDescriptionKey : NSLocalizedString(@"Not a supported URL", @"Entered wrong host"),
			  NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"Only Fanfiction.net and ArchiveOfOurOwn.org are supported at the moment.", @"Use correct host instead")}];
		return nil;
	}
}

- (id)initWithPropertyListRepresentation:(id)plist;
{
	StorySite site;
	NSString *siteIdentifier = [plist objectForKey:KeySite];
	if ([siteIdentifier isEqual:siteIdentifierFF])
		site = StorySiteFFNet;
	else if ([siteIdentifier isEqual:siteIdentifierAO3])
		site = StorySiteAO3;
	else
		return nil;
	
	return [self initWithID:[[plist objectForKey:KeyNumber] unsignedIntegerValue] site:site];
}

#pragma mark - Reachability

- (BOOL)checkIsReachableWithError:(NSError *__autoreleasing*)error;
{
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.overviewURL];
	request.HTTPMethod = @"HEAD";
	
	NSHTTPURLResponse *response;
	NSError *loadError;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&loadError];
	if (!data || response.statusCode != 200)
	{
		if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
						  NSLocalizedDescriptionKey : NSLocalizedString(@"Could not find the story", @"Download returned no data or status code != 200"),
			  NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"The story at this location could not be retrieved. Maybe it was deleted, or the internet connection is down.", @"Give correct URL"),
							   NSUnderlyingErrorKey : loadError }];
		return NO;
	}
	return YES;
}

#pragma mark - URLs

- (NSURL *)overviewURL
{
	switch (self.site)
	{
		case StorySiteFFNet:
			return [NSURL URLWithString:[NSString stringWithFormat:@"http://fanfiction.net/s/%lu/1", self.siteSpecificID]];
		case StorySiteAO3:
			return [NSURL URLWithString:[NSString stringWithFormat:@"http://archiveofourown.org/works/%lu/navigate", self.siteSpecificID]];
		default:
			return nil;
	}
}

#pragma mark - Serialisation

- (id)propertyListRepresentation
{
	NSString *siteIdentifier;
	switch (self.site)
	{
		case StorySiteFFNet:
			siteIdentifier = siteIdentifierFF;
			break;
		case StorySiteAO3:
			siteIdentifier = siteIdentifierAO3;
			break;
		default:
			return nil;
	}
	
	return @{ KeySite : siteIdentifier, KeyNumber : @(self.siteSpecificID) };
}

#pragma mark - Equality

- (NSUInteger)hash;
{
	return ((NSUInteger) self.site) | (self.siteSpecificID << 1);
}
- (BOOL)isEqual:(id)object;
{
	if (![object respondsToSelector:@selector(site)] || ![object respondsToSelector:@selector(siteSpecificID)]) return NO;
	
	return ([self siteSpecificID] == [object siteSpecificID]) && ([self site] == [object site]);
}

@end
