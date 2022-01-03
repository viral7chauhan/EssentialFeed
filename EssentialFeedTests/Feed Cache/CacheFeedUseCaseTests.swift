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
    var insertCallCount = 0

    func deleteCacheFeed() {
        deleteCacheFeedCallCount += 1
    }

    func completionDeletion(with: Error, at index: Int = 0) {

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

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItems(), uniqueItems()]
        let deletionError = anyNSError()

        sut.save(items)
        store.completionDeletion(with: deletionError)

        XCTAssertEqual(store.insertCallCount, 0)
    }

    // MARK: - Helper
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (localFeedLoader: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    func uniqueItems() -> FeedItem {
        FeedItem(id: UUID(), description: nil, location: nil, imageURL: anyURL())
    }

    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }

    private func anyNSError() -> NSError{
        NSError(domain: "Any Error", code: 1)
    }
}
