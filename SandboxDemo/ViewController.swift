//
//  ViewController.swift
//  SandboxDemo
//
//  Created by Vincent Esche on 3/11/15.
//  Copyright (c) 2015 Vincent Esche. All rights reserved.
//

import Cocoa

import Sandbox

class ViewController: NSViewController {
	
	typealias Callback = (Bool) -> ()

	@IBOutlet weak var textfield: NSTextField!
	
	@IBOutlet weak var hostWithoutSandboxButton: NSButton!
	@IBOutlet weak var hostWithSandboxButton: NSButton!
	
	@IBOutlet weak var serviceWithoutSandboxButton: NSButton!
	@IBOutlet weak var serviceWithSandboxButton: NSButton!
	
	var bookmarksManager: BookmarksManager = BookmarksManager.defaultManager
	var permissionManager: PermissionManager = PermissionManager(bookmarksManager: BookmarksManager.defaultManager)
	
	var connection: NSXPCConnection! = nil
	var service: SandboxDemoServiceProtocol! = nil
	
	override init?(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		self.commonInit_ViewController()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.commonInit_ViewController()
	}
	
	func commonInit_ViewController() {
		let connection = NSXPCConnection(serviceName: "com.regexident.SandboxDemoService")
		let remoteObjectInterface = NSXPCInterface(withProtocol: SandboxDemoServiceProtocol.self)
		connection.remoteObjectInterface = remoteObjectInterface
		connection.resume()
		self.connection = connection
		self.service = connection.remoteObjectProxyWithErrorHandler() { error in
			println("Error: %@", error.localizedDescription)
			return
		} as! SandboxDemoServiceProtocol
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.textfield.stringValue = "~/Library/"
		self.resetLabels()
	}
	
	override func controlTextDidChange(notification: NSNotification) {
		self.resetLabels()
	}
	
	func resetLabels() {
		self.hostWithoutSandboxButton.title = "❓"
		self.hostWithSandboxButton.title = "❓"
		self.serviceWithoutSandboxButton.title = "❓"
		self.serviceWithSandboxButton.title = "❓"
	}

	@IBAction func clearSecurityScopedBookmarks(sender: AnyObject) {
		self.bookmarksManager.clearSecurityScopedBookmarks()
	}
	
	@IBAction func accessFileInHostAppWithoutSandbox(sender: AnyObject) {
		self.hostWithoutSandboxButton.title = "❓"
		let path = self.textfield.stringValue.stringByExpandingTildeInPath
		let fileURL = NSURL(fileURLWithPath: path)!
		if let fileURL = NSURL(fileURLWithPath: path) {
			self.accessFileInHostAppWithoutSecurityScope(fileURL) { success in
				self.hostWithoutSandboxButton.title = (success) ? "✅" : "⛔️"
			}
		}
	}
	
	@IBAction func accessFileInHostAppWithSandbox(sender: AnyObject) {
		self.hostWithSandboxButton.title = "❓"
		let path = self.textfield.stringValue.stringByExpandingTildeInPath
		if let fileURL = NSURL(fileURLWithPath: path) {
			self.accessFileInHostAppWithSecurityScope(fileURL) { success in
				self.hostWithSandboxButton.title = (success) ? "✅" : "⛔️"
			}
		}
	}
	
	@IBAction func accessFileInXPCServiceWithoutSandbox(sender: AnyObject) {
		self.serviceWithoutSandboxButton.title = "❓"
		let path = self.textfield.stringValue.stringByExpandingTildeInPath
		if let fileURL = NSURL(fileURLWithPath: path) {
			self.accessFileInXPCServiceWithoutSecurityScope(fileURL) { success in
				self.serviceWithoutSandboxButton.title = (success) ? "✅" : "⛔️"
			}
		}
	}
	
	@IBAction func accessFileInXPCServiceWithSandbox(sender: AnyObject) {
		self.serviceWithSandboxButton.title = "❓"
		let path = self.textfield.stringValue.stringByExpandingTildeInPath
		if let fileURL = NSURL(fileURLWithPath: path) {
			self.accessFileInXPCServiceWithSecurityScope(fileURL) { success in
				self.serviceWithSandboxButton.title = (success) ? "✅" : "⛔️"
			}
		}
	}

	func accessFileInHostAppWithoutSecurityScope(fileURL: NSURL, callback: Callback) {
		let success = NSFileManager.defaultManager().isReadableFileAtPath(fileURL.path!)
		callback(success)
	}
	
	func accessFileInHostAppWithSecurityScope(fileURL: NSURL, callback: Callback) {
		self.permissionManager.accessAndIfNeededAskUserForSecurityScopeForFileAtURL(fileURL) {
			let success = NSFileManager.defaultManager().isReadableFileAtPath(fileURL.path!)
			callback(success)
		}
	}
	
	func accessFileInXPCServiceWithoutSecurityScope(fileURL: NSURL, callback: Callback) {
		self.service.accessFileWithoutSecurityScope(fileURL) { fileURL, success in
			callback(success)
		}
	}
	
	func accessFileInXPCServiceWithSecurityScope(fileURL: NSURL, callback: Callback) {
		var securityScopedURL: NSURL? = self.bookmarksManager.loadSecurityScopedURLForFileAtURL(fileURL)
		if securityScopedURL == nil {
			var error: NSError?
			securityScopedURL = self.permissionManager.askUserForSecurityScopeForFileAtURL(fileURL, error: &error)
			if (securityScopedURL == nil) && (error != nil) {
				NSApp.presentError(error!)
			}
		}
		if let securityScopedURL = securityScopedURL {
			self.bookmarksManager.saveSecurityScopedBookmarkForFileAtURL(securityScopedURL)
			self.permissionManager.accessSecurityScopedFileAtURL(securityScopedURL) {
				if let bookmark = fileURL.bookmarkDataWithOptions(NSURLBookmarkCreationOptions(), includingResourceValuesForKeys:nil, relativeToURL:nil, error:nil) {
					self.service.accessFileWithSecurityScope(bookmark) { fileURL, success in
						callback(success)
					}
				} else {
					callback(false)
				}
			}
		} else {
			callback(false)
		}
	}
	
}

