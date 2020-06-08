// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Cocoa

public class PermissionManager: NSObject {
    public let openPanelManager: OpenPanelManagerProtocol
	public let bookmarksManager: BookmarksManagerProtocol
	public var persistBookmarks: Bool = true

	public static let `default`: PermissionManager = .init()

    private let lock: NSLock = NSLock()
	
	public init(
        openPanelManager: OpenPanelManagerProtocol = OpenPanelManager(),
        bookmarksManager: BookmarksManagerProtocol = BookmarksManager()
    ) {
        self.openPanelManager = openPanelManager
		self.bookmarksManager = bookmarksManager
	}
	
	public func needsPermissionForFileAtURL(fileURL: URL) throws -> Bool {
        let reachable = try fileURL.checkResourceIsReachable()
        let readable = FileManager.default.isReadableFile(atPath: fileURL.path)
        return reachable && !readable
	}
	
	public func askUserForSecurityScope(
        fileURL: URL,
        title: String? = nil,
        message: String? = nil,
        prompt: String? = nil
    ) throws -> URL? {
        guard try self.needsPermissionForFileAtURL(fileURL: fileURL) else {
            return fileURL
        }

        return try self.openPanelManager.securityScopedURL(fileURL: fileURL).get()
	}

    @discardableResult
	public func accessSecurityScoped(
        fileURL: URL,
        _ closure: () throws -> ()
    ) rethrows -> Bool {
		let accessible = fileURL.startAccessingSecurityScopedResource()
        defer {
            fileURL.stopAccessingSecurityScopedResource()
        }
		try closure()
		return accessible
	}

    @discardableResult
	public func accessAndIfNeededAskUserForSecurityScope(
        fileURL: URL,
        _ closure: () throws -> ()
    ) throws -> Bool {
        guard try self.needsPermissionForFileAtURL(fileURL: fileURL) else {
            try closure()
            return true
        }

		self.lock.lock()
        defer {
            self.lock.unlock()
        }
        let bookmarkedURL = try self.bookmarksManager.loadSecurityScopedURL(fileURL: fileURL)
        let securityScopedURLOrNil: URL?
        if let bookmarkedURL = bookmarkedURL {
            securityScopedURLOrNil = bookmarkedURL
        } else {
            securityScopedURLOrNil = try self.askUserForSecurityScope(fileURL: fileURL)
        }
		guard let securityScopedURL = securityScopedURLOrNil else {
            return false
		}
        if self.persistBookmarks {
            try self.bookmarksManager.saveSecurityScopedBookmark(
                securityScopedFileURL: securityScopedURL
            )
        }
		return try self.accessSecurityScoped(fileURL: securityScopedURL, closure)
	}
}
