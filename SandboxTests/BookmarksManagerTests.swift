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
		
		let userDefaults = UserDefaults(suiteName: String(describing: type(of: self)))!
		self.bookmarksManager = BookmarksManager(userDefaults: userDefaults)
    }
	
	func test__defaultManager__shouldReturnSharedInstance() {
		XCTAssert(BookmarksManager.defaultManager === BookmarksManager.defaultManager)
	}

	func test__bookmarkForFileURL_error__shouldNotReturnNilForExistingFile() {
		let fileURL = NSURL(fileURLWithPath: NSHomeDirectory())
		let result = try? self.bookmarksManager.bookmarkForFileAtURL(fileURL: fileURL)
		XCTAssertNotNil(result ?? nil)
	}
	
	func test__bookmarkForFileURL_error__shouldReturnNilForNonExistingFile() {
		let fileURL = NSURL(fileURLWithPath: "/!@#$%")
		let result = try? self.bookmarksManager.bookmarkForFileAtURL(fileURL: fileURL)
		XCTAssertNil(result ?? nil)
	}
	
	func test__securityScopedBookmarkForFileURL_error__shouldNotReturnNilForExistingFile() {
		let fileURL = NSURL(fileURLWithPath: NSHomeDirectory())
        let result = try? self.bookmarksManager.securityScopedBookmarkForFileAtURL(fileURL: fileURL)
		XCTAssertNotNil(result ?? nil)
	}
	
	func test__securityScopedBookmarkForFileURL_error__shouldReturnNilForNonExistingFile() {
		let fileURL = NSURL(fileURLWithPath: "/!@#$%")
		let result = try? self.bookmarksManager.securityScopedBookmarkForFileAtURL(fileURL: fileURL)
		XCTAssertNil(result ?? nil)
	}
	
	func test__fileURLFromSecurityScopedBookmark_error__shouldNotReturnNilForValidBookmark() {
		let fileURL = NSURL(fileURLWithPath: NSHomeDirectory())
		let bookmark = try! self.bookmarksManager.securityScopedBookmarkForFileAtURL(fileURL: fileURL)!
        let result = try? self.bookmarksManager.fileURLFromSecurityScopedBookmark(bookmark: bookmark)
		XCTAssertNotNil(result ?? nil)
	}
	
	func test__fileURLFromSecurityScopedBookmark_error__shouldReturnNilForInvalidBookmark() {
		let bookmark = NSData()
        let result = try? self.bookmarksManager.fileURLFromSecurityScopedBookmark(bookmark: bookmark)
		XCTAssertNil(result ?? nil)
	}
	
	func test__saveSecurityScopedBookmark_error__shouldNotReturnTrueForValidBookmark() {
		let fileURL = NSURL(fileURLWithPath: NSHomeDirectory())
		let bookmark = try! self.bookmarksManager.securityScopedBookmarkForFileAtURL(fileURL: fileURL)!
        try! self.bookmarksManager.saveSecurityScopedBookmark(securityScopedBookmark: bookmark)
	}
	
	func test__saveSecurityScopedBookmark_error__shouldReturnFalseForInvalidBookmark() {
		let bookmark = NSData()
        XCTAssertThrowsError(try self.bookmarksManager.saveSecurityScopedBookmark(securityScopedBookmark: bookmark))
	}
	
	func test__saveSecurityScopedBookmark_error__shouldAddBookmark() {
		let fileURL = NSURL(fileURLWithPath: NSHomeDirectory())
		let bookmark = try! self.bookmarksManager.securityScopedBookmarkForFileAtURL(fileURL: fileURL)!
		try! self.bookmarksManager.saveSecurityScopedBookmark(securityScopedBookmark: bookmark)
		let result = self.bookmarksManager.loadSecurityScopedBookmarkForFileAtURL(fileURL: fileURL)
		if let result = result {
			XCTAssertEqual(result, bookmark)
		} else {
			XCTFail("Unexpected nil")
		}
	}
	
	func test__loadSecurityScopedBookmarkForFileURL__shouldReturnNilForNonExistingBookmark() {
		let fileURL = NSURL(fileURLWithPath: "/!@#$%")
		let result = self.bookmarksManager.loadSecurityScopedBookmarkForFileAtURL(fileURL: fileURL)
		XCTAssertNil(result)
	}
	
	func test__loadSecurityScopedBookmarkForFileURL__shouldReturnProperBookmark() {
		let fileURL = NSURL(fileURLWithPath: NSHomeDirectory())
		let bookmark = try! self.bookmarksManager.securityScopedBookmarkForFileAtURL(fileURL: fileURL)!
		try! self.bookmarksManager.saveSecurityScopedBookmark(securityScopedBookmark: bookmark)
		let result = self.bookmarksManager.loadSecurityScopedBookmarkForFileAtURL(fileURL: fileURL)
		if let result = result {
			XCTAssertEqual(result, bookmark)
		} else {
			XCTFail("Unexpected nil")
		}
	}
	
	func test__loadSecurityScopedBookmarkForFileURL__shouldReturnBookmarkOfParentDirectory() {
		let fileURL = NSURL(fileURLWithPath:NSHomeDirectory())
		let bookmark = try! self.bookmarksManager.securityScopedBookmarkForFileAtURL(fileURL: fileURL)!
		try! self.bookmarksManager.saveSecurityScopedBookmark(securityScopedBookmark: bookmark)
        let result = self.bookmarksManager.loadSecurityScopedBookmarkForFileAtURL(fileURL: fileURL.appendingPathComponent("Foo")! as NSURL)
		if let result = result {
			XCTAssertEqual(result, bookmark)
		} else {
			XCTFail("Unexpected nil")
		}
	}
	
	func test__bookmarkedFileURLs__shouldReturnProperFileURLs() {
		let fileURL = NSURL(fileURLWithPath:NSHomeDirectory())
		let bookmark = try! self.bookmarksManager.securityScopedBookmarkForFileAtURL(fileURL: fileURL)!
		try! self.bookmarksManager.saveSecurityScopedBookmark(securityScopedBookmark: bookmark)
		let result = self.bookmarksManager.bookmarkedFileURLs
		XCTAssertEqual(result, Set<NSURL>([fileURL]))
	}
}
