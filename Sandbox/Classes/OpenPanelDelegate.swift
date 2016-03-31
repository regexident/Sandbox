//
//  OpenPanelDelegate.swift
//  Sandbox
//
//  Created by Vincent Esche on 3/10/15.
//  Copyright (c) 2015 Vincent Esche. All rights reserved.
//

import Cocoa

public class OpenPanelDelegate: NSObject, OpenPanelDelegateType {

	public var fileURL: NSURL!
	
	public func panel(sender: AnyObject, shouldEnableURL url: NSURL) -> Bool {
		let lhsComponents = self.fileURL.pathComponents!
		let rhsComponents = url.pathComponents!
		if lhsComponents.count >= rhsComponents.count {
			let count = rhsComponents.count
			return lhsComponents[0..<count] == rhsComponents[0..<count]
		}
		return false
	}
	
}
