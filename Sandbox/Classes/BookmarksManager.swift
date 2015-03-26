//
//  BookmarksManager.swift
//  Sandbox
//
//  Created by Vincent Esche on 3/10/15.
//  Copyright (c) 2015 Vincent Esche. All rights reserved.
//

import Foundation

public class BookmarksManager {
	
	public let userDefaults: NSUserDefaults
	
	public static let defaultManager: BookmarksManager = BookmarksManager()
	
	private static let userDefaultsBookmarksKey = "Sandbox.BookmarksManager.Bookmarks"
	
	private var securityScopedBookmarksByFilePath: [String: NSData] {
		get {
			let bookmarksByFilePath = self.userDefaults.dictionaryForKey(BookmarksManager.userDefaultsBookmarksKey) as? [String: NSData]
			return bookmarksByFilePath ?? [:]
		}
		set {
			self.userDefaults.setObject(newValue, forKey: BookmarksManager.userDefaultsBookmarksKey)
		}
	}
	
	public var bookmarkedFileURLs: Set<NSURL> {
		let filePaths = self.securityScopedBookmarksByFilePath.keys.array
		let fileURLs = filePaths.map { NSURL(fileURLWithPath: $0)! }
		return Set<NSURL>(fileURLs)
	}
	
	public init() {
		self.userDefaults = NSUserDefaults.standardUserDefaults()
	}
	
	public init(userDefaults: NSUserDefaults) {
		self.userDefaults = userDefaults
	}
	
	public func clearSecurityScopedBookmarks() {
		self.securityScopedBookmarksByFilePath = [:]
	}
	
	public func bookmarkForFileAtURL(fileURL: NSURL, error: NSErrorPointer) -> NSData? {
		let resolvesFileURL = fileURL.URLByStandardizingPath?.URLByResolvingSymlinksInPath
		let bookmark = resolvesFileURL?.bookmarkDataWithOptions(NSURLBookmarkCreationOptions(), includingResourceValuesForKeys: nil, relativeToURL: nil, error: error)
		return bookmark
	}
	
	public func securityScopedBookmarkForFileAtURL(fileURL: NSURL, error: NSErrorPointer) -> NSData?{
		let resolvesFileURL = fileURL.URLByStandardizingPath?.URLByResolvingSymlinksInPath
		let bookmark = resolvesFileURL?.bookmarkDataWithOptions(NSURLBookmarkCreationOptions.WithSecurityScope, includingResourceValuesForKeys: nil, relativeToURL: nil, error: error)
		return bookmark
	}
	
	public func fileURLFromSecurityScopedBookmark(bookmark: NSData, error: NSErrorPointer) -> NSURL? {
		let options = NSURLBookmarkResolutionOptions.WithSecurityScope | NSURLBookmarkResolutionOptions.WithoutUI
		var stale: ObjCBool = false;
		let fileURL = NSURL(byResolvingBookmarkData: bookmark, options: options, relativeToURL: nil, bookmarkDataIsStale: &stale, error: error)
		if (stale) {
			debugPrintln("Bookmark is stale.")
			return nil
		}
		return fileURL;
	}
	
	public func loadSecurityScopedURLForFileAtURL(fileURL: NSURL) -> NSURL? {
		if let bookmark = self.loadSecurityScopedBookmarkForFileAtURL(fileURL) {
			return self.fileURLFromSecurityScopedBookmark(bookmark, error:nil)
		}
		return nil
	}
	
	public func loadSecurityScopedBookmarkForFileAtURL(fileURL: NSURL) -> NSData? {
		if var resolvedFileURL = fileURL.URLByStandardizingPath?.URLByResolvingSymlinksInPath {
			let bookmarksByFilePath = self.securityScopedBookmarksByFilePath
			var securityScopedBookmark = bookmarksByFilePath[resolvedFileURL.path!]
			while (securityScopedBookmark == nil) && (resolvedFileURL.pathComponents!.count > 1) {
				resolvedFileURL = resolvedFileURL.URLByDeletingLastPathComponent!
				securityScopedBookmark = bookmarksByFilePath[resolvedFileURL.path!]
			}
			return securityScopedBookmark
		} else {
			return nil
		}
	}
	
	public func saveSecurityScopedBookmarkForFileAtURL(securityScopedFileURL: NSURL, error: NSErrorPointer = nil) -> Bool {
		let success: Bool
		var error = NSErrorPointer()
		if let bookmark = self.securityScopedBookmarkForFileAtURL(securityScopedFileURL, error:error) {
			success = self.saveSecurityScopedBookmark(bookmark, error:error)
		} else {
			success = false
		}
		return success
	}
	
	public func saveSecurityScopedBookmark(securityScopedBookmark: NSData, error: NSErrorPointer) -> Bool {
		let success: Bool
		if let fileURL = self.fileURLFromSecurityScopedBookmark(securityScopedBookmark, error:error) {
			var securityScopedBookmarksByFilePath = self.securityScopedBookmarksByFilePath
			securityScopedBookmarksByFilePath[fileURL.path!] = securityScopedBookmark
			self.securityScopedBookmarksByFilePath = securityScopedBookmarksByFilePath
			success = true
		} else {
			success = false
		}
		return success
	}
	
	public func deleteSecurityScopedBookmarkForFileAtURL(fileURL: NSURL) {
		if let resolvedFileURL = fileURL.URLByStandardizingPath?.URLByResolvingSymlinksInPath {
			var securityScopedBookmarksByFilePath = self.securityScopedBookmarksByFilePath
			securityScopedBookmarksByFilePath.removeValueForKey(fileURL.path!)
			self.securityScopedBookmarksByFilePath = securityScopedBookmarksByFilePath
		}
	}
}
