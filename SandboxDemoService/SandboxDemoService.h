//
//  SandboxDemoService.h
//  SandboxDemoService
//
//  Created by Vincent Esche on 3/23/15.
//  Copyright (c) 2015 Vincent Esche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SandboxDemoServiceProtocol.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface SandboxDemoService : NSObject <SandboxDemoServiceProtocol>

@end
