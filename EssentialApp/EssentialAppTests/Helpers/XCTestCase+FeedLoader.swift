//
//  XCTestCase+FeedLoader.swift
//  EssentialAppTests
//
//  Created by Viral on 10/10/22.
//

import XCTest
import EssentialFeed

protocol FeedLoaderTestCases: XCTestCase {}

extension FeedLoaderTestCases {
    func expect(_ sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result,
                        file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait to load completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
                case let (.success(receviedFeed), .success(expectedFeed)):
                    XCTAssertEqual(receviedFeed, expectedFeed, file: file, line: line)

                case (.failure, .failure):
                    break

                default:
                    XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
}
