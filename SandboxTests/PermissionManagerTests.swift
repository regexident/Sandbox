//
//  PermissionManagerTests.swift
//  Sandbox
//
//  Created by Vincent Esche on 3/25/15.
//  Copyright (c) 2015 Vincent Esche. All rights reserved.
//

import Cocoa
import XCTest

import Sandbox

class PermissionManagerTests: XCTestCase {
	
	var permissionManager: PermissionManager!
	
    override func setUp() {
        super.setUp()
		
		self.permissionManager = PermissionManager()
    }
    
}
