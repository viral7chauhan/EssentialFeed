//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Viral on 02/01/22.
//

import XCTest
import EssentialFeed

class FeedStore {
    var deleteCacheFeedCallCount = 0

    func deleteCacheFeed() {
        deleteCacheFeedCallCount += 1
    }
}

class LocalFeedLoader {
    let store: FeedStore
    init(store: FeedStore) {
        self.store = store
    }

    func save(_ item: [FeedItem]) {
        store.deleteCacheFeed()
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteItemOnCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
    }

    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItems(), uniqueItems()]

        sut.save(items)

        XCTAssertEqual(store.deleteCacheFeedCallCount, 1)
    }

    // MARK: - Helper
    func makeSUT() -> (localFeedLoader: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        return (sut, store)
    }

    func uniqueItems() -> FeedItem {
        FeedItem(id: UUID(), description: nil, location: nil, imageURL: anyURL())
    }

    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
}
