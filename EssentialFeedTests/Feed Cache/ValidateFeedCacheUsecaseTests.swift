//
//  ValidateFeedCacheUsecaseTests.swift
//  EssentialFeedTests
//
//  Created by Viral on 20/01/22.
//

import XCTest
import EssentialFeed

class ValidateFeedCacheUsecaseTests: XCTestCase {

    func test_init_doesNotDeleteOnMessageCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMsg, [])
    }

    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()

        sut.validateCache()
        store.completeRetrieval(with: anyNSError())

        XCTAssertEqual(store.receivedMsg, [.retrieve, .deletion])
    }

    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.validateCache()
        store.completeRetrieveWithEmptyCache()

        XCTAssertEqual(store.receivedMsg, [.retrieve])
    }

    func test_validateCache_doesNotDeleteNonExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.validateCache()
        store.completeRetrieve(with: feed.local, timestamp: nonExpiredTimestamp)

        XCTAssertEqual(store.receivedMsg, [.retrieve])
    }

    func test_validation_deletesCacheOnExpiration() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.validateCache()
        store.completeRetrieve(with: feed.local, timestamp: expirationTimestamp)

        XCTAssertEqual(store.receivedMsg, [.retrieve, .deletion])
    }

    func test_validation_deletesExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.validateCache()
        store.completeRetrieve(with: feed.local, timestamp: expiredTimestamp)

        XCTAssertEqual(store.receivedMsg, [.retrieve, .deletion])
    }

    func test_validateCache_doestNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

        sut?.validateCache()
        sut = nil

        store.completeRetrieval(with: anyNSError())
        XCTAssertEqual(store.receivedMsg, [.retrieve])
    }

    // MARK: - Helper

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (localFeedLoader: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
}
