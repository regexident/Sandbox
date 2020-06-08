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
	
	typealias Callback = (Bool) throws -> ()

	@IBOutlet weak var textfield: NSTextField!
	
	@IBOutlet weak var hostWithoutSandboxButton: NSButton!
	@IBOutlet weak var hostWithSandboxButton: NSButton!
	
	@IBOutlet weak var serviceWithoutSandboxButton: NSButton!
	@IBOutlet weak var serviceWithSandboxButton: NSButton!
	
	var bookmarksManager: BookmarksManager = BookmarksManager.defaultManager
	var permissionManager: PermissionManager = PermissionManager(bookmarksManager: BookmarksManager.defaultManager)
	
	var connection: NSXPCConnection! = nil
	var service: SandboxDemoServiceProtocol! = nil
	
	override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		self.commonInit()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.commonInit()
	}
	
	func commonInit() {
		let connection = NSXPCConnection(serviceName: "com.regexident.SandboxDemoService")
		let remoteObjectInterface = NSXPCInterface(with: SandboxDemoServiceProtocol.self)
		connection.remoteObjectInterface = remoteObjectInterface
		connection.resume()
		self.connection = connection
		self.service = connection.remoteObjectProxyWithErrorHandler() { error in
			print("Error: %@", error.localizedDescription)
			return
		} as? SandboxDemoServiceProtocol
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.textfield.stringValue = "~/Library/"
		self.resetLabels()
	}
	
	func controlTextDidChange(notification: NSNotification) {
		self.resetLabels()
	}
	
	func resetLabels() {
		self.hostWithoutSandboxButton.title = "❓"
		self.hostWithSandboxButton.title = "❓"
		self.serviceWithoutSandboxButton.title = "❓"
		self.serviceWithSandboxButton.title = "❓"
	}

	@IBAction func clearSecurityScopedBookmarks(_ sender: AnyObject) {
		self.bookmarksManager.clearSecurityScopedBookmarks()
	}
	
	@IBAction func accessFileInHostAppWithoutSandbox(_ sender: AnyObject) {
		self.hostWithoutSandboxButton.title = "❓"
		let path = (self.textfield.stringValue as NSString).expandingTildeInPath
		let fileURL = URL(fileURLWithPath: path)
        self.accessFileInHostAppWithoutSecurityScope(fileURL: fileURL) { success in
            self.hostWithoutSandboxButton.title = (success) ? "✅" : "⛔️"
        }
	}
	
	@IBAction func accessFileInHostAppWithSandbox(_ sender: AnyObject) {
		self.hostWithSandboxButton.title = "❓"
        let path = (self.textfield.stringValue as NSString).expandingTildeInPath
		let fileURL = URL(fileURLWithPath: path)
        self.accessFileInHostAppWithSecurityScope(fileURL: fileURL) { success in
            self.hostWithSandboxButton.title = (success) ? "✅" : "⛔️"
        }
    }
	
	@IBAction func accessFileInXPCServiceWithoutSandbox(_ sender: AnyObject) {
		self.serviceWithoutSandboxButton.title = "❓"
        let path = (self.textfield.stringValue as NSString).expandingTildeInPath
		let fileURL = URL(fileURLWithPath: path)
        self.accessFileInXPCServiceWithoutSecurityScope(fileURL: fileURL) { success in
            DispatchQueue.main.async {
                self.serviceWithoutSandboxButton.title = (success) ? "✅" : "⛔️"
            }
        }
	}
	
	@IBAction func accessFileInXPCServiceWithSandbox(_ sender: AnyObject) {
		self.serviceWithSandboxButton.title = "❓"
        let path = (self.textfield.stringValue as NSString).expandingTildeInPath
		let fileURL = URL(fileURLWithPath: path)
        do {
            try self.accessFileInXPCServiceWithSecurityScope(fileURL: fileURL) { success in
                DispatchQueue.main.async {
                    self.serviceWithSandboxButton.title = (success) ? "✅" : "⛔️"
                }
            }
        } catch let error {
            print("Error:", error)
        }
    }

	func accessFileInHostAppWithoutSecurityScope(fileURL: URL, callback: Callback) rethrows {
		let success = FileManager.default.isReadableFile(atPath: fileURL.path)
		try callback(success)
	}
	
	func accessFileInHostAppWithSecurityScope(fileURL: URL, callback: Callback) rethrows {
        _ = try? self.permissionManager.accessAndIfNeededAskUserForSecurityScope(fileURL: fileURL) {
			let success = FileManager.default.isReadableFile(atPath: fileURL.path)
			try callback(success)
		}
	}
	
	func accessFileInXPCServiceWithoutSecurityScope(fileURL: URL, callback: @escaping Callback) rethrows {
        self.service.accessFileWithoutSecurityScope( fileURL) { fileURL, success in
            do {
                try callback(success)
            } catch let error {
                print("Error:", error)
            }
		}
	}
	
    func accessFileInXPCServiceWithSecurityScope(fileURL: URL, callback: @escaping Callback) throws {
        var securityScopedURLOrNil: URL? = try self.bookmarksManager.loadSecurityScopedURL(fileURL: fileURL)
		if securityScopedURLOrNil == nil {
            securityScopedURLOrNil = try self.permissionManager.askUserForSecurityScope(fileURL: fileURL)
		}
		guard let securityScopedURL = securityScopedURLOrNil else {
            try callback(false)
            return
		}
        do {
            try self.bookmarksManager.saveSecurityScopedBookmark(securityScopedFileURL: securityScopedURL)
            try self.permissionManager.accessSecurityScoped(fileURL: securityScopedURL) {
                let bookmark = try fileURL.bookmarkData(
                    options: URL.BookmarkCreationOptions(),
                    includingResourceValuesForKeys: nil,
                    relativeTo: nil
                )
                self.service.accessFile(withSecurityScope: bookmark) { fileURL, success in
                    do {
                        try callback(success)
                    } catch let error {
                        NSApp.presentError(error)
                    }
                }
            }
        } catch let error {
            NSApp.presentError(error)
        }
	}
}
