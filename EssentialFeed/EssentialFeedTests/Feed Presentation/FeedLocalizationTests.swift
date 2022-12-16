//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Viral on 10/06/22.
//

import XCTest
import EssentialFeed

class FeedLocalizationTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
}
