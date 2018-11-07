//
//  TestDateInRegion+Langs.swift
//  SwiftDate
//
//  Created by Daniele Margutti on 29/06/2018.
//  Copyright © 2018 SwiftDate. All rights reserved.
//

import SwiftDate
import XCTest

class TestDateInRegion_Langs: XCTestCase {

	public func testLanguages() {

		RelativeFormatter.allLanguages.forEach { langType in
			XCTAssert((langType.identifier.isEmpty == false), "Language \(langType) has not a valid identifier")
			let langInstance = langType.init()
			langInstance.flavours.forEach({ (key, value) in
				if RelativeFormatter.Flavour(rawValue: key) == nil {
					XCTFail("Flavour '\(key)' is not supported by the library (lang '\(langType.identifier)'")
					return
				}
				guard let flavourDict = value as? [String: Any] else {
					XCTFail("Flavour dictionary '\(key)' is not a valid dictionary")
					return
				}
				flavourDict.keys.forEach({ rawTimeUnit in
					if RelativeFormatter.Unit(rawValue: rawTimeUnit) == nil {
						XCTFail("Time unit '\(rawTimeUnit)' in lang \(key) is not a valid")
						return
					}
				})
			})
		}
	}

}
