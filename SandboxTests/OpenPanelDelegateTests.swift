//
//  OpenPanelDelegateTests.swift
//  Sandbox
//
//  Created by Vincent Esche on 3/11/15.
//  Copyright (c) 2015 Vincent Esche. All rights reserved.
//

import Cocoa
import XCTest

import Sandbox

class OpenPanelDelegateTests: XCTestCase {

	var panel: NSOpenPanel!
	var delegate: OpenPanelDelegate!
	
    override func setUp() {
        super.setUp()
		
		self.panel = NSOpenPanel()
		
		let fileURL = NSURL(fileURLWithPath: NSHomeDirectory())
		self.delegate = OpenPanelDelegate()
		self.delegate.fileURL = fileURL
    }
	
	func test__panel_shouldEnableURL__shouldReturnTrueForFileItself() {
		let fileURL = self.delegate.fileURL!
        let result = self.delegate.panel(sender: self.panel, shouldEnableURL: fileURL)
		XCTAssertTrue(result)
	}
	
	func test__panel_shouldEnableURL__shouldReturnTrueForParentDirectory() {
		let fileURL = self.delegate.fileURL.deletingLastPathComponent! as NSURL
        let result = self.delegate.panel(sender: self.panel, shouldEnableURL:fileURL)
		XCTAssertTrue(result);
	}
	
	func test__panel_shouldEnableURL__shouldReturnTrueForUnrelatedFile() {
		let fileURL = self.delegate.fileURL.deletingLastPathComponent!.appendingPathComponent("Foobar") as NSURL
        let result = self.delegate.panel(sender: self.panel, shouldEnableURL: fileURL)
		XCTAssertFalse(result);
	}
	
}
