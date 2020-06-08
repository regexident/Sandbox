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
