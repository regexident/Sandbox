//
//  SandboxDemoServiceProtocol.h
//  SandboxDemoService
//
//  Created by Vincent Esche on 3/23/15.
//  Copyright (c) 2015 Vincent Esche. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SandboxDemoServiceReply)(NSURL *fileURl, BOOL success);

@protocol SandboxDemoServiceProtocol

- (void)accessFileWithoutSecurityScope:(NSURL *)fileURL reply:(SandboxDemoServiceReply)reply;
- (void)accessFileWithSecurityScope:(NSData *)bookmark reply:(SandboxDemoServiceReply)reply;
	
@end
