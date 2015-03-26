//
//  SandboxDemoService.m
//  SandboxDemoService
//
//  Created by Vincent Esche on 3/23/15.
//  Copyright (c) 2015 Vincent Esche. All rights reserved.
//

#import "SandboxDemoService.h"

@implementation SandboxDemoService

- (void)accessFileWithoutSecurityScope:(NSURL *)fileURL reply:(SandboxDemoServiceReply)reply {
	reply(fileURL, [self canAccessFileAtURL:fileURL]);
}

- (void)accessFileWithSecurityScope:(NSData *)bookmark reply:(SandboxDemoServiceReply)reply {
	NSURL *fileURL = [NSURL URLByResolvingBookmarkData:bookmark options:NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:nil error:nil];
	reply(fileURL, [self canAccessFileAtURL:fileURL]);
}

- (BOOL)canAccessFileAtURL:(NSURL *)fileURL {
	return [[NSFileManager defaultManager] isReadableFileAtPath:fileURL.path];
}

@end
