//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Viral on 30/01/22.
//

import EssentialFeed
import XCTest

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {

    func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {

        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)

        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
    }

    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {

        insert((uniqueImageFeed().local, Date()), to: sut)

        expect(sut, toRetrieve: .empty, file: file, line: line)
    }

}
