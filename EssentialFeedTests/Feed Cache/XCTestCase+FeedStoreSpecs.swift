//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Viral on 28/01/22.
//

import EssentialFeed
import XCTest

extension FeedStoreSpecs where Self: XCTestCase {
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }

    func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieval")

        sut.retrieve { retrieveResult in
            switch (expectedResult, retrieveResult) {
                case (.empty, .empty),
                    (.failure, .failure):
                    break

                case let (.found(expectedFeed, expectedTimestamp), .found(retrievedFeed, retrievedTimestamp)):
                    XCTAssertEqual(expectedFeed, retrievedFeed, file: file, line: line)
                    XCTAssertEqual(expectedTimestamp, retrievedTimestamp, file: file, line: line)

                default:
                    XCTFail("Expected to retrieve \(expectedResult), got \(retrieveResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for insertion")
        var insertError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { insertionError in
            insertError = insertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertError
    }

    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "wait for deletion")
        var deleteError: Error?
        sut.deleteCacheFeed { deletetionError in
            deleteError = deletetionError
            exp.fulfill()
        }

        wait(for: [exp], timeout: 10.0)
        return deleteError
    }
}
