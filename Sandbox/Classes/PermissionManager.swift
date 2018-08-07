//
//  PermissionManager.swift
//  Sandbox
//
//  Created by Vincent Esche on 3/10/15.
//  Copyright (c) 2015 Vincent Esche. All rights reserved.
//

import Cocoa

public protocol OpenPanelDelegateType : AnyObject, NSOpenSavePanelDelegate {

	var fileURL: NSURL! { get set }
	
}

public class PermissionManager {
	
	public let bookmarksManager: BookmarksManager
	public var persistBookmarks: Bool = true
	public lazy var openPanelDelegate: OpenPanelDelegateType = OpenPanelDelegate()
	public lazy var openPanel: NSOpenPanel = OpenPanelBuilder().openPanel()

	public static let defaultManager: PermissionManager = PermissionManager()
	
	private let lock: NSLock = NSLock()
	
	public init(bookmarksManager: BookmarksManager = BookmarksManager()) {
		self.bookmarksManager = bookmarksManager
	}
	
	public func needsPermissionForFileAtURL(fileURL: NSURL, error: NSErrorPointer = nil) -> Bool {
		let reachable = fileURL.checkResourceIsReachableAndReturnError(error)
		let readable = FileManager.default.isReadableFile(atPath: fileURL.path!)
		return reachable && !readable
	}
	
	public func askUserForSecurityScopeForFileAtURL(fileURL: NSURL, error: NSErrorPointer = nil) -> NSURL? {
		if !self.needsPermissionForFileAtURL(fileURL: fileURL, error: error) {
			return fileURL
		}
		
		let openPanel = self.openPanel

		if openPanel.directoryURL == nil {
			openPanel.directoryURL = fileURL.deletingLastPathComponent
		}
		
		let openPanelDelegate = self.openPanelDelegate
		openPanelDelegate.fileURL = fileURL
		openPanel.delegate = openPanelDelegate
		
		var securityScopedURL: NSURL? = nil
		
		let closure: () -> () = {
			NSApplication.shared.activate(ignoringOtherApps: true)
			if openPanel.runModal().rawValue == NSFileHandlingPanelOKButton {
				securityScopedURL = openPanel.url as NSURL?
			}
			openPanel.delegate = nil
		}
		
		if Thread.isMainThread {
			closure()
		} else {
            DispatchQueue.main.sync(execute: closure)            
		}
		
		return securityScopedURL
	}
	
	public func accessSecurityScopedFileAtURL(fileURL: NSURL, closure: () -> ()) -> Bool {
		var accessible = false
		accessible = fileURL.startAccessingSecurityScopedResource()
		closure()
		fileURL.stopAccessingSecurityScopedResource()
		return accessible
	}
	
	public func accessAndIfNeededAskUserForSecurityScopeForFileAtURL(fileURL: NSURL, closure: () -> ()) throws -> Bool {
		if !self.needsPermissionForFileAtURL(fileURL: fileURL) {
			closure()
			return true
		}
		self.lock.lock()
		let bookmarkedURL = self.bookmarksManager.loadSecurityScopedURLForFileAtURL(fileURL: fileURL)
		let securityScopedURL = bookmarkedURL ?? self.askUserForSecurityScopeForFileAtURL(fileURL: fileURL)
		if (securityScopedURL != nil) && self.persistBookmarks {
            try self.bookmarksManager.saveSecurityScopedBookmarkForFileAtURL(securityScopedFileURL: securityScopedURL!)
		}
		self.lock.unlock()
		if securityScopedURL != nil {
			return self.accessSecurityScopedFileAtURL(fileURL: securityScopedURL!, closure: closure)
		}
		return false
	}
	
}
