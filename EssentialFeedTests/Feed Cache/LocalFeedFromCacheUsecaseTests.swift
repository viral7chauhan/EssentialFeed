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
        let retrievelError = anyNSError()
        let exp = expectation(description: "Wait for load retrieval")

        var receivedError: Error?
        sut.load { error in
            receivedError = error
            exp.fulfill()
        }
        store.completeRetrieval(with: retrievelError)
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedError as? NSError, retrievelError)
    }

    // MARK: - Helper

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (localFeedLoader: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func anyNSError() -> NSError{
        NSError(domain: "Any Error", code: 1)
    }
}
