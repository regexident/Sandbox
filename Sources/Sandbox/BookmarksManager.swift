// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public protocol BookmarksManagerProtocol {
    func clearSecurityScopedBookmarks()

    func bookmark(fileURL: URL) throws -> Data
    func securityScopedBookmark(fileURL: URL) throws -> Data

    func fileURLFromSecurityScopedBookmark(data: Data) throws -> URL?

    func loadSecurityScopedURL(fileURL: URL) throws -> URL?
    func loadSecurityScopedBookmark(fileURL: URL) -> Data?

    func saveSecurityScopedBookmark(securityScopedFileURL: URL) throws
    func saveSecurityScopedBookmark(data securityScopedBookmark: Data) throws

    func deleteSecurityScopedBookmark(fileURL: URL)
}

public class BookmarksManager {
	public let userDefaults: UserDefaults
	
	public static let defaultManager: BookmarksManager = BookmarksManager()
	
	private static let userDefaultsBookmarksKey = "Sandbox.BookmarksManager.Bookmarks"
	
	private var securityScopedBookmarksByFilePath: [String: Data] {
		get {
            let bookmarksByFilePath = self.userDefaults.dictionary(
                forKey: BookmarksManager.userDefaultsBookmarksKey
            ) as? [String: Data]
			return bookmarksByFilePath ?? [:]
		}
		set {
			self.userDefaults.set(newValue, forKey: BookmarksManager.userDefaultsBookmarksKey)
		}
	}
	
	public var bookmarkedFileURLs: Set<URL> {
		let filePaths = self.securityScopedBookmarksByFilePath.keys
		let fileURLs = filePaths.map { URL(fileURLWithPath: $0) }
		return Set<URL>(fileURLs)
	}
	
	public init() {
		self.userDefaults = UserDefaults.standard
	}
	
	public init(userDefaults: UserDefaults) {
		self.userDefaults = userDefaults
	}
	
	public func clearSecurityScopedBookmarks() {
		self.securityScopedBookmarksByFilePath = [:]
	}
}

extension BookmarksManager: BookmarksManagerProtocol {
	public func bookmark(fileURL: URL) throws -> Data {
        try fileURL.bookmarkData(
            options: [],
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
	}
	
	public func securityScopedBookmark(fileURL: URL) throws -> Data {
		return try fileURL.bookmarkData(
            options: [.withSecurityScope],
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
	}
	
	public func fileURLFromSecurityScopedBookmark(data: Data) throws -> URL? {
		let options: URL.BookmarkResolutionOptions = [.withSecurityScope, .withoutUI]
		var isStale: Bool = false
        let fileURL = try URL(
            resolvingBookmarkData: data,
            options: options,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )
		if isStale {
			return nil
		}
		return fileURL
	}

	public func loadSecurityScopedURL(fileURL: URL) throws -> URL? {
		guard let bookmark = self.loadSecurityScopedBookmark(fileURL: fileURL) else {
            return nil
		}
		return try self.fileURLFromSecurityScopedBookmark(data: bookmark)
	}
	
	public func loadSecurityScopedBookmark(fileURL: URL) -> Data? {
		let bookmarksByFilePath = self.securityScopedBookmarksByFilePath
        var securityScopedBookmark = bookmarksByFilePath[fileURL.path]
        var fileURL = fileURL
        while (securityScopedBookmark == nil) && (fileURL.pathComponents.count > 1) {
            fileURL = fileURL.deletingLastPathComponent()
            let filePath = fileURL.path
            securityScopedBookmark = bookmarksByFilePath[filePath]
        }
        return securityScopedBookmark
	}
	
	public func saveSecurityScopedBookmark(securityScopedFileURL: URL) throws {
		let bookmark = try self.securityScopedBookmark(fileURL: securityScopedFileURL)
        return try self.saveSecurityScopedBookmark(data: bookmark)
	}
	
	public func saveSecurityScopedBookmark(data securityScopedBookmark: Data) throws {
		guard let fileURL = try self.fileURLFromSecurityScopedBookmark(data: securityScopedBookmark) else {
			return
		}
        let filePath = fileURL.path
        self.securityScopedBookmarksByFilePath[filePath] = securityScopedBookmark
	}
	
	public func deleteSecurityScopedBookmark(fileURL: URL) {
        let filePath = fileURL.path
        self.securityScopedBookmarksByFilePath.removeValue(forKey: filePath)
    }
}
