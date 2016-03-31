//
//  NSURL+CommonURLs.swift
//  Sandbox
//
//  Created by Vincent Esche on 3/25/15.
//  Copyright (c) 2015 Vincent Esche. All rights reserved.
//

import Foundation

extension NSURL {
	
	public class func groupByCommonPrefixURLs_sbx(urls: [NSURL], groupByLongest: Bool = true) -> [NSURL: [NSURL]] {
		var prefix: [String] = []
		var group: [NSURL] = []
		var groups: [NSURL: [NSURL]] = [:]
		let urlsAsComponents = urls.map { $0.URLByResolvingSymlinksInPath!.pathComponents! }
		let sortedUrlsAsComponents = urlsAsComponents.sort() {
			for (lhs, rhs) in zip($0, $1) {
				if lhs != rhs {
					return lhs < rhs
				}
			}
			return $0.count < $1.count
		}
		for current in sortedUrlsAsComponents {
			if prefix.count == 0 {
				prefix = current
			} else if group.count > 0 {
				let previous = group.last!.pathComponents!
				let common = commonPrefixOfPathComponents_sbx(current, previous)
				if common.count < prefix.count {
					groups[NSURL.fileURLWithPathComponents(prefix)!] = group
					prefix = common
					group = []
				} else {
					prefix = common
				}
			}
			group.append(NSURL.fileURLWithPathComponents(current)!)
		}
		if group.count > 0 {
			groups[NSURL.fileURLWithPathComponents(prefix)!] = group
		}
		return groups
	}
	
	public class func commonURLPrefixOf_sbx<S: SequenceType where S.Generator.Element == NSURL>(urlSequence: S) -> NSURL? {
		var commonURL: NSURL?
		for url in urlSequence {
			if commonURL != nil {
				if let newCommonURL = commonURL!.commonURLPrefixWith_sbx(url) {
					commonURL = newCommonURL
				} else {
					return nil
				}
			} else {
				commonURL = url
			}
		}
		return commonURL
	}
	
	public func commonURLPrefixWith_sbx(url: NSURL) -> NSURL? {
		let lhsPathComponents = self.URLByResolvingSymlinksInPath?.pathComponents
		let rhsPathComponents = url.URLByResolvingSymlinksInPath?.pathComponents
		if let lhsPathComponents = lhsPathComponents, rhsPathComponents = rhsPathComponents {
			if !NSURL.existsCommonURLForFileURLsWithPathComponents_sbx(lhsPathComponents, rhsPathComponents) {
				return nil
			}
			let common = NSURL.commonPrefixOfPathComponents_sbx(lhsPathComponents, rhsPathComponents)
			return NSURL.fileURLWithPathComponents(common)!
		}
		return nil
	}
	
	public func existsCommonURLWith_sbx(url: NSURL) -> Bool {
		let lhs = self.URLByResolvingSymlinksInPath?.pathComponents
		let rhs = url.URLByResolvingSymlinksInPath?.pathComponents
		if let lhs = lhs, rhs = rhs {
			return NSURL.existsCommonURLForFileURLsWithPathComponents_sbx(lhs, rhs)
		}
		return false
	}
	
	private class func existsCommonURLForFileURLsWithPathComponents_sbx(lhs: [String], _ rhs: [String]) -> Bool {
		if (lhs.count <= 1) && (rhs.count <= 1) {
			return true
		}
		let volumesComponent = "Volumes"
		let lhsHasVolume = lhs[1] == volumesComponent
		let rhsHasVolume = rhs[1] == volumesComponent
		if lhsHasVolume != rhsHasVolume {
			return false
		} else if (lhsHasVolume && rhsHasVolume) && (lhs[2] != rhs[2]) {
			return false
		}
		return true
	}
	
	private class func commonPrefixOfPathComponents_sbx(lhs: [String], _ rhs: [String]) -> ([String]) {
		var prefix = [String]()
		for pair in zip(lhs, rhs) {
			if pair.0 != pair.1 {
				break
			}
			prefix.append(pair.0)
		}
		return prefix
	}
	
}
