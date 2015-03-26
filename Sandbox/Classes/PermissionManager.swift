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
		let readable = NSFileManager.defaultManager().isReadableFileAtPath(fileURL.path!)
		return reachable && !readable
	}
	
	public func askUserForSecurityScopeForFileAtURL(fileURL: NSURL, error: NSErrorPointer = nil) -> NSURL? {
		if !self.needsPermissionForFileAtURL(fileURL, error: error) {
			return fileURL
		}
		
		let openPanel = self.openPanel

		if openPanel.directoryURL == nil {
			openPanel.directoryURL = fileURL.URLByDeletingLastPathComponent
		}
		
		let openPanelDelegate = self.openPanelDelegate ?? OpenPanelDelegate()
		openPanelDelegate.fileURL = fileURL
		openPanel.delegate = openPanelDelegate
		
		var securityScopedURL: NSURL? = nil
		
		let closure: () -> () = {
			NSApplication.sharedApplication().activateIgnoringOtherApps(true)
			if openPanel.runModal() == NSFileHandlingPanelOKButton {
				securityScopedURL = openPanel.URL
			}
			openPanel.delegate = nil
		}
		
		if NSThread.isMainThread() {
			closure()
		} else {
			dispatch_sync(dispatch_get_main_queue(), closure)
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
	
	public func accessAndIfNeededAskUserForSecurityScopeForFileAtURL(fileURL: NSURL, closure: () -> ()) -> Bool {
		if !self.needsPermissionForFileAtURL(fileURL) {
			closure()
			return true
		}
		self.lock.lock()
		let securityScopedURL = self.bookmarksManager.loadSecurityScopedURLForFileAtURL(fileURL) ?? self.askUserForSecurityScopeForFileAtURL(fileURL)
		if (securityScopedURL != nil) && self.persistBookmarks {
			self.bookmarksManager.saveSecurityScopedBookmarkForFileAtURL(securityScopedURL!)
		}
		self.lock.unlock()
		if securityScopedURL != nil {
			return self.accessSecurityScopedFileAtURL(securityScopedURL!, closure: closure)
		}
		return false
	}
	
}
