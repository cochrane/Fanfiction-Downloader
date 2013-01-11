//
//  MockURLProtocol.m
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 11.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "MockURLProtocol.h"

// Roughly following http://www.infinite-loop.dk/blog/2011/09/using-nsurlprotocol-for-injecting-test-data/

static NSMutableDictionary *dataForURL;

@implementation MockURLProtocol

+ (void)initialize
{
	dataForURL = [NSMutableDictionary dictionary];
}

+ (void)clearMockData
{
	[dataForURL removeAllObjects];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
	if (![request.URL.scheme isEqual:@"http"]) return NO;
	if (![request.HTTPMethod isEqual:@"GET"] || [request.HTTPMethod isEqual:@"HEAD"]) return NO;
	
	return YES;
}

+ (void)setData:(NSData *)data forURL:(NSURL *)url;
{
	[dataForURL setObject:data forKey:url];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
	return request;
}

- (void)startLoading
{	
	NSData *resultData = [dataForURL objectForKey:self.request.URL];
	
	if (!resultData)
	{
		NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:@{ NSURLErrorFailingURLErrorKey : self.request.URL }];
		[self.client URLProtocol:self didFailWithError:error];
	}
	
	NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{}];
	
	[self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
	[self.client URLProtocol:self didLoadData:resultData];
	[self.client URLProtocolDidFinishLoading:self];
}


- (void)stopLoading
{
	// Empty
}

@end
