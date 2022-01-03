//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Viral on 02/01/22.
//

import XCTest
import EssentialFeed

class FeedStore {
    typealias DeleteCompletion = (Error?) -> Void
    var deleteCacheFeedCallCount = 0
    var insertCallCount = 0

    var insertItems = [(items: [FeedItem], timestamp: Date)]()
    private var deleteCompletions = [DeleteCompletion]()

    func deleteCacheFeed(completion: @escaping (Error?) -> Void) {
        deleteCacheFeedCallCount += 1
        deleteCompletions.append(completion)
    }

    func completionDeletion(with error: Error, at index: Int = 0) {
        deleteCompletions[index](error)
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
        deleteCompletions[index](nil)
    }

    func insert(_ items: [FeedItem], timestamp: Date) {
        insertCallCount += 1
        insertItems.append((items, timestamp))
    }
}

class LocalFeedLoader {
    let store: FeedStore
    let timestamp: () -> Date
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.timestamp = currentDate
    }

    func save(_ items: [FeedItem]) {
        store.deleteCacheFeed { [unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: self.timestamp())
            }
        }
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

    func test_save_requestNewCacheInsertionOnSuccessfulDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItems(), uniqueItems()]

        sut.save(items)
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.insertCallCount, 1)
    }

    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let items = [uniqueItems(), uniqueItems()]

        sut.save(items)
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.insertItems.count, 1)
        XCTAssertEqual(store.insertItems.first?.items, items)
        XCTAssertEqual(store.insertItems.first?.timestamp, timestamp)
    }

    // MARK: - Helper
    func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (localFeedLoader: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
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
