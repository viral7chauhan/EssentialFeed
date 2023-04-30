//
//  LocalFeedFromCacheUsecaseTests.swift
//  EssentialFeedTests
//
//  Created by Viral on 12/01/22.
//

import XCTest
import EssentialFeed

class LocalFeedFromCacheUsecaseTests: XCTestCase {

    func test_init_doesNotDeleteOnMessageCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMsg, [])
    }

    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        sut.load { _ in }
        XCTAssertEqual(store.receivedMsg, [.retrieve])
    }

    func test_load_failsOnRetrievelError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()

        expect(sut, onCompleteWith: .failure(retrievalError)) {
            store.completeRetrieval(with: retrievalError)
        }

    }

    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()

        expect(sut, onCompleteWith: .success([])) {
            store.completeRetrieveWithEmptyCache()
        }
    }

    func test_load_delivesCachedImagesOnNonExpiredCache() {

        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, onCompleteWith: .success(feed.models)) {
            store.completeRetrieve(with: feed.local, timestamp: nonExpiredTimestamp)
        }
    }

    func test_load_delivesNoImagesOnCacheExpiration() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, onCompleteWith: .success([])) {
            store.completeRetrieve(with: feed.local, timestamp: expirationTimestamp)
        }
    }

    func test_load_delivesNoImagesOnExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredCacheTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, onCompleteWith: .success([])) {
            store.completeRetrieve(with: feed.local, timestamp: expiredCacheTimestamp)
        }
    }

    func test_load_hasNoSideEffectsOnRetrievalError() {
        let (sut, store) = makeSUT()

		store.completeRetrieval(with: anyNSError())
        sut.load { _ in }

        XCTAssertEqual(store.receivedMsg, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (sut, store) = makeSUT()

		store.completeRetrieveWithEmptyCache()
        sut.load { _ in }

        XCTAssertEqual(store.receivedMsg, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnNonExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

		store.completeRetrieve(with: feed.local, timestamp: nonExpiredTimestamp)
        sut.load { _ in }

        XCTAssertEqual(store.receivedMsg, [.retrieve])
    }

    func test_load_hasNoSideEffectOnCacheExpirationCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

		store.completeRetrieve(with: feed.local, timestamp: expirationTimestamp)
        sut.load { _ in }

        XCTAssertEqual(store.receivedMsg, [.retrieve])
    }

    func test_load_hasNoSideEffectOnExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

		store.completeRetrieve(with: feed.local, timestamp: expiredTimestamp)
        sut.load { _ in }

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

    private func expect(_ sut: LocalFeedLoader, onCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {

        let exp = expectation(description: "Wait for load retrieval")
		action()
		
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
                case let (.success(receivedImages), .success(expectedImages)):
                    XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
                case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                    XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                default:
                    XCTFail("Expected result \(expectedResult), got \(receivedResult) result instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
