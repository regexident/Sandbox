//
//  NSURLTests.swift
//  Sandbox
//
//  Created by Vincent Esche on 3/25/15.
//  Copyright (c) 2015 Vincent Esche. All rights reserved.
//

import Cocoa
import XCTest

import Sandbox

class NSURLTests: XCTestCase {
	
	func test__existsCommonURLWith_sbx__returnsTrueIfExistsCommonURL() {
		let firstFile = NSURL(fileURLWithPath: "/path/to/file")
		let secondFile = NSURL(fileURLWithPath: "/path/to/another/file")
		let result = firstFile.existsCommonURLWith_sbx(url: secondFile)
		XCTAssertTrue(result)
	}
	
	func test__existsCommonURLWith_sbx__returnsFalseIfNotExistsCommonURL() {
		let firstFile = NSURL(fileURLWithPath: "/Volumes/foo")
		let secondFile = NSURL(fileURLWithPath: "/bar/baz")
		let result = firstFile.existsCommonURLWith_sbx(url: secondFile)
		XCTAssertFalse(result)
	}
	
	func test__existsCommonURLWith_sbx__returnsNilIfCrossingVolumeBoundaries() {
		let firstFile = NSURL(fileURLWithPath: "/Volumes/foo")
		let secondFile = NSURL(fileURLWithPath: "/bar/baz")
		let result = firstFile.commonURLPrefixWith_sbx(url: secondFile)
		XCTAssertNil(result)
	}
	
	func test__commonURLWith_sbx__returnsProperPrefixURLIfExists() {
		let firstFile = NSURL(fileURLWithPath: "/path/to/file")
		let secondFile = NSURL(fileURLWithPath: "/path/to/another/file")
		let result = firstFile.commonURLPrefixWith_sbx(url: secondFile)
		XCTAssertEqual(result, NSURL(fileURLWithPath: "/path/to"))
	}
	
	func test__commonURLWith_sbx__returnsNilIfNotExists() {
		let firstFile = NSURL(fileURLWithPath: "/Volumes/foo")
		let secondFile = NSURL(fileURLWithPath: "/bar/baz")
		let result = firstFile.commonURLPrefixWith_sbx(url: secondFile)
		XCTAssertNil(result)
	}
	
	func test__commonURLPrefixOf_sbx__returnsCommonPrefixURLIfExists() {
		let fileURLs = [
			NSURL(fileURLWithPath: "/path/to/file"),
			NSURL(fileURLWithPath: "/path/to/another/file"),
			NSURL(fileURLWithPath: "/path/to"),
		]
		let result = NSURL.commonURLPrefixOf_sbx(urlSequence: fileURLs)
		XCTAssertEqual(result!, NSURL(fileURLWithPath: "/path/to"))
	}
	
	func test__commonURLPrefixOf_sbx__returnsNilIfNotExists() {
		let fileURLs = [
			NSURL(fileURLWithPath: "/path/to/file"),
			NSURL(fileURLWithPath: "/path/to/another/file"),
			NSURL(fileURLWithPath: "/Volumes/foo"),
		]
		let result = NSURL.commonURLPrefixOf_sbx(urlSequence: fileURLs)
		XCTAssertNil(result)
	}
	
	func test__groupByCommonPrefixURLs_sbx__returnsGroupedURLs() {
		let fileURLs = [
			NSURL(fileURLWithPath: "/path/to/file"),
			NSURL(fileURLWithPath: "/path/to/another/file"),
			NSURL(fileURLWithPath: "/path/a/b"),
			NSURL(fileURLWithPath: "/path/a/c"),
			NSURL(fileURLWithPath: "/path/a"),
			NSURL(fileURLWithPath: "/Volumes/foo"),
		]
		let validation: [NSURL: [NSURL]] = [
			NSURL(fileURLWithPath: "/path/to"): [
				NSURL(fileURLWithPath: "/path/to/file"),
				NSURL(fileURLWithPath: "/path/to/another/file"),
			],
			NSURL(fileURLWithPath: "/path/a"): [
				NSURL(fileURLWithPath: "/path/a/b"),
				NSURL(fileURLWithPath: "/path/a/c"),
				NSURL(fileURLWithPath: "/path/a"),
			],
			NSURL(fileURLWithPath: "/Volumes/foo"): [
				NSURL(fileURLWithPath: "/Volumes/foo"),
			],
		]
		let result = NSURL.groupByCommonPrefixURLs_sbx(urls: fileURLs)
		
		let resultKeys = Set<NSURL>(result.keys)
		let validationKeys = Set<NSURL>(validation.keys)
		XCTAssertEqual(resultKeys, validationKeys)
		
		for key in resultKeys {
			let resultValue = result[key]
			let validationValue = validation[key]
			XCTAssertNotNil(resultValue)
			XCTAssertNotNil(validationValue)
			XCTAssertEqual(Set<NSURL>(resultValue!), Set<NSURL>(validationValue!))
		}
		
	}
	
}
