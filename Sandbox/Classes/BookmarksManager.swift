//
//  BookmarksManager.swift
//  Sandbox
//
//  Created by Vincent Esche on 3/10/15.
//  Copyright (c) 2015 Vincent Esche. All rights reserved.
//

import Foundation

public class BookmarksManager {
	
	public let userDefaults: UserDefaults
	
	public static let defaultManager: BookmarksManager = BookmarksManager()
	
	private static let userDefaultsBookmarksKey = "Sandbox.BookmarksManager.Bookmarks"
	
	private var securityScopedBookmarksByFilePath: [String: NSData] {
		get {
            let bookmarksByFilePath = self.userDefaults.dictionary(forKey: BookmarksManager.userDefaultsBookmarksKey) as? [String: NSData]
			return bookmarksByFilePath ?? [:]
		}
		set {
			self.userDefaults.set(newValue, forKey: BookmarksManager.userDefaultsBookmarksKey)
		}
	}
	
	public var bookmarkedFileURLs: Set<NSURL> {
		let filePaths = self.securityScopedBookmarksByFilePath.keys
		let fileURLs = filePaths.map { NSURL(fileURLWithPath: $0) }
		return Set<NSURL>(fileURLs)
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
	
	public func bookmarkForFileAtURL(fileURL: NSURL) throws -> NSData? {
		let resolvesFileURL = fileURL.standardizingPath?.resolvingSymlinksInPath()
        let bookmark = try resolvesFileURL?.bookmarkData(options: NSURL.BookmarkCreationOptions(), includingResourceValuesForKeys: nil, relativeTo: nil)
		return bookmark as NSData?
	}
	
	public func securityScopedBookmarkForFileAtURL(fileURL: NSURL) throws -> NSData?{
		let resolvesFileURL = fileURL.standardizingPath?.resolvingSymlinksInPath()
        let bookmark = try resolvesFileURL?.bookmarkData(options: NSURL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
		return bookmark as NSData?
	}
	
	public func fileURLFromSecurityScopedBookmark(bookmark: NSData) throws -> NSURL? {
		let options: NSURL.BookmarkResolutionOptions = [.withSecurityScope, .withoutUI]
		var stale: ObjCBool = false;
		let fileURL = try NSURL(resolvingBookmarkData: bookmark as Data, options: options, relativeTo: nil, bookmarkDataIsStale: &stale)
		if (stale.boolValue) {
			debugPrint("Bookmark is stale.")
			return nil
		}
		return fileURL;
	}
	
	public func loadSecurityScopedURLForFileAtURL(fileURL: NSURL) -> NSURL? {
		if let bookmark = self.loadSecurityScopedBookmarkForFileAtURL(fileURL: fileURL) {
			do {
				return try self.fileURLFromSecurityScopedBookmark(bookmark: bookmark)
			} catch let error {
				debugPrint("Error: \(error)")
			}
		}
		return nil
	}
	
	public func loadSecurityScopedBookmarkForFileAtURL(fileURL: NSURL) -> NSData? {
		if var resolvedFileURL = fileURL.standardizingPath?.resolvingSymlinksInPath() {
			let bookmarksByFilePath = self.securityScopedBookmarksByFilePath
			var securityScopedBookmark = bookmarksByFilePath[resolvedFileURL.path]
			while (securityScopedBookmark == nil) && (resolvedFileURL.pathComponents.count > 1) {
				resolvedFileURL = resolvedFileURL.deletingLastPathComponent()
				securityScopedBookmark = bookmarksByFilePath[resolvedFileURL.path]
			}
			return securityScopedBookmark
		} else {
			return nil
		}
	}
	
	public func saveSecurityScopedBookmarkForFileAtURL(securityScopedFileURL: NSURL, error: NSErrorPointer = nil) throws {
		if let bookmark = try self.securityScopedBookmarkForFileAtURL(fileURL: securityScopedFileURL) {
			return try self.saveSecurityScopedBookmark(securityScopedBookmark: bookmark)
		}
	}
	
	public func saveSecurityScopedBookmark(securityScopedBookmark: NSData) throws {
		if let fileURL = try self.fileURLFromSecurityScopedBookmark(bookmark: securityScopedBookmark) {
			var securityScopedBookmarksByFilePath = self.securityScopedBookmarksByFilePath
			securityScopedBookmarksByFilePath[fileURL.path!] = securityScopedBookmark
			self.securityScopedBookmarksByFilePath = securityScopedBookmarksByFilePath
		}
	}
	
	public func deleteSecurityScopedBookmarkForFileAtURL(fileURL: NSURL) {
        if let resolvedFileURL = fileURL.standardizingPath?.resolvingSymlinksInPath() {
			var securityScopedBookmarksByFilePath = self.securityScopedBookmarksByFilePath
            securityScopedBookmarksByFilePath.removeValue(forKey: resolvedFileURL.path)
			self.securityScopedBookmarksByFilePath = securityScopedBookmarksByFilePath
		}
	}
}
