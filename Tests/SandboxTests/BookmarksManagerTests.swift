import Cocoa
import XCTest

import Sandbox

class BookmarksManagerTests: XCTestCase {
    func bookmarksManager(scope: String) -> BookmarksManager {
        let userDefaults = UserDefaults(suiteName: scope)!
        return BookmarksManager(userDefaults: userDefaults)
    }

	func test__bookmarkForFileURL_error__shouldNotReturnNilForExistingFile() throws {
        let bookmarksManager = self.bookmarksManager(scope: #function)

		let fileURL = URL(fileURLWithPath: NSHomeDirectory())
        let result = try bookmarksManager.bookmark(fileURL: fileURL)

        XCTAssertNotNil(result)
	}
	
	func test__bookmarkForFileURL_error__shouldReturnNilForNonExistingFile() throws {
        let bookmarksManager = self.bookmarksManager(scope: #function)

		let fileURL = URL(fileURLWithPath: "/!@#$%")

        XCTAssertThrowsError(try bookmarksManager.bookmark(fileURL: fileURL))
	}
	
	func test__securityScopedBookmarkForFileURL_error__shouldNotReturnNilForExistingFile() throws {
        let bookmarksManager = self.bookmarksManager(scope: #function)

		let fileURL = URL(fileURLWithPath: NSHomeDirectory())
        let result = try bookmarksManager.securityScopedBookmark(fileURL: fileURL)

        XCTAssertNotNil(result)
	}
	
	func test__securityScopedBookmarkForFileURL_error__shouldReturnNilForNonExistingFile() throws {
        let bookmarksManager = self.bookmarksManager(scope: #function)

		let fileURL = URL(fileURLWithPath: "/!@#$%")

        XCTAssertThrowsError(try bookmarksManager.securityScopedBookmark(fileURL: fileURL))
	}
	
	func test__fileURLFromSecurityScopedBookmark_error__shouldNotReturnNilForValidBookmark() throws {
        let bookmarksManager = self.bookmarksManager(scope: #function)

		let fileURL = URL(fileURLWithPath: NSHomeDirectory())
        let bookmark = try bookmarksManager.securityScopedBookmark(fileURL: fileURL)
        let result = try bookmarksManager.fileURLFromSecurityScopedBookmark(data: bookmark)

        XCTAssertNotNil(result)
	}
	
	func test__fileURLFromSecurityScopedBookmark_error__shouldReturnNilForInvalidBookmark() throws {
        let bookmarksManager = self.bookmarksManager(scope: #function)

		let bookmark = Data()

        XCTAssertThrowsError(try bookmarksManager.fileURLFromSecurityScopedBookmark(data: bookmark))
	}
	
	func test__saveSecurityScopedBookmark_error__shouldNotReturnTrueForValidBookmark() throws {
        let bookmarksManager = self.bookmarksManager(scope: #function)

		let fileURL = URL(fileURLWithPath: NSHomeDirectory())
        let bookmark = try bookmarksManager.securityScopedBookmark(fileURL: fileURL)
        try bookmarksManager.saveSecurityScopedBookmark(data: bookmark)
	}
	
	func test__saveSecurityScopedBookmark_error__shouldReturnFalseForInvalidBookmark() throws {
        let bookmarksManager = self.bookmarksManager(scope: #function)

		let bookmark = Data()

        XCTAssertThrowsError(try bookmarksManager.saveSecurityScopedBookmark(data: bookmark))
	}
	
	func test__saveSecurityScopedBookmark_error__shouldAddBookmark() throws {
        let bookmarksManager = self.bookmarksManager(scope: #function)

		let fileURL = URL(fileURLWithPath: NSHomeDirectory())
        let bookmark = try bookmarksManager.securityScopedBookmark(fileURL: fileURL)
        try bookmarksManager.saveSecurityScopedBookmark(data: bookmark)
        let result = bookmarksManager.loadSecurityScopedBookmark(fileURL: fileURL)

		XCTAssertEqual(result, bookmark)
	}
	
	func test__loadSecurityScopedBookmarkForFileURL__shouldReturnNilForNonExistingBookmark() throws {
        let bookmarksManager = self.bookmarksManager(scope: #function)

		let fileURL = URL(fileURLWithPath: "/!@#$%")
        let result = bookmarksManager.loadSecurityScopedBookmark(fileURL: fileURL)

		XCTAssertNil(result)
	}
	
	func test__loadSecurityScopedBookmarkForFileURL__shouldReturnProperBookmark() throws {
        let bookmarksManager = self.bookmarksManager(scope: #function)

		let fileURL = URL(fileURLWithPath: NSHomeDirectory())
        let bookmark = try bookmarksManager.securityScopedBookmark(fileURL: fileURL)
        try bookmarksManager.saveSecurityScopedBookmark(data: bookmark)
        let result = bookmarksManager.loadSecurityScopedBookmark(fileURL: fileURL)

		XCTAssertEqual(result, bookmark)
	}
	
	func test__loadSecurityScopedBookmarkForFileURL__shouldReturnBookmarkOfParentDirectory() throws {
        let bookmarksManager = self.bookmarksManager(scope: #function)

		let fileURL = URL(fileURLWithPath: NSHomeDirectory())
        let bookmark = try bookmarksManager.securityScopedBookmark(fileURL: fileURL)
        try bookmarksManager.saveSecurityScopedBookmark(data: bookmark)
        let result = bookmarksManager.loadSecurityScopedBookmark(
            fileURL: fileURL.appendingPathComponent("Foo")
        )

		XCTAssertEqual(result, bookmark)
	}
	
	func test__bookmarkedFileURLs__shouldReturnProperFileURLs() throws {
        let bookmarksManager = self.bookmarksManager(scope: #function)

		let fileURL = URL(fileURLWithPath: NSHomeDirectory())
        let bookmark = try bookmarksManager.securityScopedBookmark(fileURL: fileURL)
        try bookmarksManager.saveSecurityScopedBookmark(data: bookmark)
		let result = bookmarksManager.bookmarkedFileURLs

		XCTAssertEqual(result, [fileURL])
	}
}
