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

    func test_load_delivesCachedImagesOnLessThanSevenDaysOldCache() {

        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, onCompleteWith: .success(feed.models)) {
            store.completeRetrieve(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
        }
    }

    func test_load_delivesNoImagesOnSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, onCompleteWith: .success([])) {
            store.completeRetrieve(with: feed.local, timestamp: sevenDaysOldTimestamp)
        }
    }

    func test_load_delivesNoImagesOnMoreThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, onCompleteWith: .success([])) {
            store.completeRetrieve(with: feed.local, timestamp: moreThanSevenDaysOldTimestamp)
        }
    }

    func test_load_doesNotDeliversErrorOnRetrievalWhenStoreDeinitialized() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedError: Error?

        sut?.load { result in
            switch result {
                case let .failure(error):
                    receivedError = error

                default:
                    XCTFail("This case should fail")
            }
        }

        sut = nil
        store.completeRetrieval(with: anyNSError())

        XCTAssertNil(receivedError)
    }

    func test_load_hasNoSideEffectsOnRetrievalError() {
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())

        XCTAssertEqual(store.receivedMsg, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetrieveWithEmptyCache()

        XCTAssertEqual(store.receivedMsg, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnLessThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.load { _ in }
        store.completeRetrieve(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)

        XCTAssertEqual(store.receivedMsg, [.retrieve])
    }

    func test_load_hasNoSideEffectOnSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.load { _ in }
        store.completeRetrieve(with: feed.local, timestamp: sevenDaysOldTimestamp)

        XCTAssertEqual(store.receivedMsg, [.retrieve])
    }

    func test_load_hasNoSideEffectOnMoreThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.load { _ in }
        store.completeRetrieve(with: feed.local, timestamp: moreThanSevenDaysOldTimestamp)

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
        action()
        wait(for: [exp], timeout: 1.0)
    }
}