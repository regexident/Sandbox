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
		let urlsAsComponents = urls.map { $0.resolvingSymlinksInPath!.pathComponents }
        let sortedUrlsAsComponents = urlsAsComponents.sorted(by: {
			for (lhs, rhs) in zip($0, $1) {
				if lhs != rhs {
					return lhs < rhs
				}
			}
			return $0.count < $1.count
		})
		for current in sortedUrlsAsComponents {
			if prefix.count == 0 {
				prefix = current
			} else if group.count > 0 {
				let previous = group.last!.pathComponents!
                let common = commonPrefixOfPathComponents_sbx(lhs: current, rhs: previous)
				if common.count < prefix.count {
					groups[NSURL.fileURL(withPathComponents: prefix)! as NSURL] = group
					prefix = common
					group = []
				} else {
					prefix = common
				}
			}
			group.append(NSURL.fileURL(withPathComponents: current)! as NSURL)
		}
		if group.count > 0 {
            groups[NSURL.fileURL(withPathComponents: prefix)! as NSURL] = group
		}
		return groups
	}
	
    public class func commonURLPrefixOf_sbx<S: Sequence>(urlSequence: S) -> NSURL? where S.Iterator.Element == NSURL {
		var commonURL: NSURL?
		for url in urlSequence {
			if commonURL != nil {
				if let newCommonURL = commonURL!.commonURLPrefixWith_sbx(url: url) {
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
		let lhsPathComponents = self.resolvingSymlinksInPath?.pathComponents
		let rhsPathComponents = url.resolvingSymlinksInPath?.pathComponents
		if let lhsPathComponents = lhsPathComponents, let rhsPathComponents = rhsPathComponents {
            if !NSURL.existsCommonURLForFileURLsWithPathComponents_sbx(lhs: lhsPathComponents, rhs: rhsPathComponents) {
				return nil
			}
            let common = NSURL.commonPrefixOfPathComponents_sbx(lhs: lhsPathComponents, rhs: rhsPathComponents)
            return NSURL.fileURL(withPathComponents: common)! as NSURL
		}
		return nil
	}
	
	public func existsCommonURLWith_sbx(url: NSURL) -> Bool {
		let lhs = self.resolvingSymlinksInPath?.pathComponents
		let rhs = url.resolvingSymlinksInPath?.pathComponents
		if let lhs = lhs, let rhs = rhs {
            return NSURL.existsCommonURLForFileURLsWithPathComponents_sbx(lhs: lhs, rhs: rhs)
		}
		return false
	}
	
	private class func existsCommonURLForFileURLsWithPathComponents_sbx(lhs: [String], rhs: [String]) -> Bool {
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
	
	private class func commonPrefixOfPathComponents_sbx(lhs: [String], rhs: [String]) -> ([String]) {
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
