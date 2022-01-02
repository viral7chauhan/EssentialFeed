//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Viral on 02/01/22.
//

import XCTest

class FeedStore {
    var deleteCacheFeedCallCount = 0
}

class LocalFeedLoader {
    init(store: FeedStore) {}

}

class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteItemOnCreation() {
        let store = FeedStore()
        let _ = LocalFeedLoader(store: store)
        XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
    }
}
