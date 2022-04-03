//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Viral on 03/04/22.
//

import XCTest

class FeedViewController {
    init(loader: FeedViewControllerTests.LoaderSpy) {

    }
}

class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)

        XCTAssertEqual(loader.loadCallCount, 0)
    }

    class LoaderSpy {
        private(set) var loadCallCount = 0
    }
}
