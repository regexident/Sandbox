//
//  OpenPanelBuilder.swift
//  Sandbox
//
//  Created by Vincent Esche on 3/25/15.
//  Copyright (c) 2015 Vincent Esche. All rights reserved.
//

import Foundation

public class OpenPanelBuilder {
	
	public let title: String
	public let message: String
	public let prompt: String
	
	init(applicationName: String? = nil) {
		self.title = OpenPanelBuilder.defaultTitle()
		self.message = OpenPanelBuilder.defaultMessage(applicationName: applicationName)
		self.prompt = OpenPanelBuilder.defaultPrompt()
	}
	
	init(title: String, message: String, prompt: String) {
		self.title = title
		self.message = message
		self.prompt = prompt
	}
	
	public func openPanel() -> NSOpenPanel {
		var openPanel: NSOpenPanel! = nil
		
		let closure: () -> () = {
			openPanel = NSOpenPanel()
			
			openPanel.allowsMultipleSelection = false
			openPanel.canChooseDirectories = true
			openPanel.canChooseFiles = true
			openPanel.canCreateDirectories = false
			openPanel.isExtensionHidden = false
			openPanel.showsHiddenFiles = false
			
			openPanel.title = self.title
			openPanel.message = self.message
			openPanel.prompt = self.prompt
		}
		
		if Thread.isMainThread {
			closure()
		} else {
            DispatchQueue.main.sync(execute: closure)
		}
		
		return openPanel
	}
	
	public static func applicationName() -> String {
		let mainBundle = Bundle.main
		if let displayName = mainBundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
			return displayName
		}
        if let bundleName = mainBundle.object(forInfoDictionaryKey: "CFBundleName") as? String {
			return bundleName
		}
		return "Current App"
	}
	
	private static func defaultTitle() -> String {
		return NSLocalizedString("Access permissions required", comment: "Sandbox open panel title")
	}
	
	private static func defaultMessage(applicationName: String?) -> String {
		let formatString = NSLocalizedString("Please allow '%@' to access this file or folder to continue.", comment: "Sandbox open panel message.")
		let formatArgument = applicationName ?? OpenPanelBuilder.applicationName()
		return String(format: formatString, formatArgument)
	}
	
	private static func defaultPrompt() -> String {
		return NSLocalizedString("Allow", comment: "Sandbox open panel prompt.")
	}
	
}