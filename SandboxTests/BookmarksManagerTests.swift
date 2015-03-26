//
//  BookmarksManagerTests.swift
//  Sandbox
//
//  Created by Vincent Esche on 3/10/15.
//  Copyright (c) 2015 Vincent Esche. All rights reserved.
//

import Cocoa
import XCTest

import Sandbox

class BookmarksManagerTests: XCTestCase {

	var bookmarksManager: BookmarksManager!
	
    override func setUp() {
        super.setUp()
		
		let userDefaults = NSUserDefaults(suiteName: toString(self.dynamicType))!
		self.bookmarksManager = BookmarksManager(userDefaults: userDefaults)
    }
	
	func test__defaultManager__shouldReturnSharedInstance() {
		XCTAssert(BookmarksManager.defaultManager === BookmarksManager.defaultManager)
	}

	func test__bookmarkForFileURL_error__shouldNotReturnNilForExistingFile() {
		let fileURL = NSURL(fileURLWithPath: NSHomeDirectory())!
		let result = self.bookmarksManager.bookmarkForFileAtURL(fileURL, error:nil)
		XCTAssertNotNil(result)
	}
	
	func test__bookmarkForFileURL_error__shouldReturnNilForNonExistingFile() {
		let fileURL = NSURL(fileURLWithPath: "/!@#$%")!
		let result = self.bookmarksManager.bookmarkForFileAtURL(fileURL, error:nil)
		XCTAssertNil(result)
	}
	
	func test__securityScopedBookmarkForFileURL_error__shouldNotReturnNilForExistingFile() {
		let fileURL = NSURL(fileURLWithPath: NSHomeDirectory())!
		let result = self.bookmarksManager.securityScopedBookmarkForFileAtURL(fileURL, error:nil)
		XCTAssertNotNil(result)
	}
	
	func test__securityScopedBookmarkForFileURL_error__shouldReturnNilForNonExistingFile() {
		let fileURL = NSURL(fileURLWithPath: "/!@#$%")!
		let result = self.bookmarksManager.securityScopedBookmarkForFileAtURL(fileURL, error:nil)
		XCTAssertNil(result)
	}
	
	func test__fileURLFromSecurityScopedBookmark_error__shouldNotReturnNilForValidBookmark() {
		let fileURL = NSURL(fileURLWithPath: NSHomeDirectory())!
		let bookmark = self.bookmarksManager.securityScopedBookmarkForFileAtURL(fileURL, error:nil)!
		let result = self.bookmarksManager.fileURLFromSecurityScopedBookmark(bookmark, error:nil)
		XCTAssertNotNil(result)
	}
	
	func test__fileURLFromSecurityScopedBookmark_error__shouldReturnNilForInvalidBookmark() {
		let bookmark = NSData()
		let result = self.bookmarksManager.fileURLFromSecurityScopedBookmark(bookmark, error:nil)
		XCTAssertNil(result)
	}
	
	func test__saveSecurityScopedBookmark_error__shouldNotReturnTrueForValidBookmark() {
		let fileURL = NSURL(fileURLWithPath: NSHomeDirectory())!
		let bookmark = self.bookmarksManager.securityScopedBookmarkForFileAtURL(fileURL, error:nil)!
		let result = self.bookmarksManager.saveSecurityScopedBookmark(bookmark, error:nil)
		XCTAssertTrue(result)
	}
	
	func test__saveSecurityScopedBookmark_error__shouldReturnFalseForInvalidBookmark() {
		let bookmark = NSData()
		let result = self.bookmarksManager.saveSecurityScopedBookmark(bookmark, error:nil)
		XCTAssertFalse(result)
	}
	
	func test__saveSecurityScopedBookmark_error__shouldAddBookmark() {
		let fileURL = NSURL(fileURLWithPath: NSHomeDirectory())!
		let bookmark = self.bookmarksManager.securityScopedBookmarkForFileAtURL(fileURL, error:nil)!
		self.bookmarksManager.saveSecurityScopedBookmark(bookmark, error:nil)
		let result = self.bookmarksManager.loadSecurityScopedBookmarkForFileAtURL(fileURL)
		if let result = result {
			XCTAssertEqual(result, bookmark)
		} else {
			XCTFail("Unexpected nil")
		}
	}
	
	func test__loadSecurityScopedBookmarkForFileURL__shouldReturnNilForNonExistingBookmark() {
		let fileURL = NSURL(fileURLWithPath: "/!@#$%")!
		let result = self.bookmarksManager.loadSecurityScopedBookmarkForFileAtURL(fileURL)
		XCTAssertNil(result)
	}
	
	func test__loadSecurityScopedBookmarkForFileURL__shouldReturnProperBookmark() {
		let fileURL = NSURL(fileURLWithPath: NSHomeDirectory())!
		let bookmark = self.bookmarksManager.securityScopedBookmarkForFileAtURL(fileURL, error:nil)!
		self.bookmarksManager.saveSecurityScopedBookmark(bookmark, error:nil)
		let result = self.bookmarksManager.loadSecurityScopedBookmarkForFileAtURL(fileURL)
		if let result = result {
			XCTAssertEqual(result, bookmark)
		} else {
			XCTFail("Unexpected nil")
		}
	}
	
	func test__loadSecurityScopedBookmarkForFileURL__shouldReturnBookmarkOfParentDirectory() {
		let fileURL = NSURL(fileURLWithPath:NSHomeDirectory())!
		let bookmark = self.bookmarksManager.securityScopedBookmarkForFileAtURL(fileURL, error:nil)!
		self.bookmarksManager.saveSecurityScopedBookmark(bookmark, error:nil)
		let result = self.bookmarksManager.loadSecurityScopedBookmarkForFileAtURL(fileURL.URLByAppendingPathComponent("Foo"))
		if let result = result {
			XCTAssertEqual(result, bookmark)
		} else {
			XCTFail("Unexpected nil")
		}
	}
	
	func test__bookmarkedFileURLs__shouldReturnProperFileURLs() {
		let fileURL = NSURL(fileURLWithPath:NSHomeDirectory())!
		let bookmark = self.bookmarksManager.securityScopedBookmarkForFileAtURL(fileURL, error:nil)!
		self.bookmarksManager.saveSecurityScopedBookmark(bookmark, error:nil)
		let result = self.bookmarksManager.bookmarkedFileURLs
		XCTAssertEqual(result, Set<NSURL>([fileURL]))
	}
}
