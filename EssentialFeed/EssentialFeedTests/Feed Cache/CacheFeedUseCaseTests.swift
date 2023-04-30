//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Viral on 02/01/22.
//

import XCTest
import EssentialFeed

class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteOnMessageCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMsg, [])
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = uniqueImageFeed()
        let deletionError = anyNSError()

		store.completeDeletion(with: deletionError)
        try? sut.save(items.models)

        XCTAssertEqual(store.receivedMsg, [.deletion])
    }

    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let items = uniqueImageFeed()

		store.completeDeletionSuccessfully()
        try? sut.save(items.models)

        XCTAssertEqual(store.receivedMsg, [.deletion, .insert(feed: items.local, timestamp: timestamp)])
    }

    func test_save_failedOnCacheDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()

        expect(sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }

    func test_save_failedOnCacheInsertionError() {
        let (sut, store) = makeSUT()
        let insertError = anyNSError()

        expect(sut, toCompleteWithError: insertError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertError)
        }
    }

    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWithError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }

    // MARK: - Helper
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (localFeedLoader: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, action: ()-> Void,
                file: StaticString = #filePath, line: UInt = #line) {
		do {
			try sut.save(uniqueImageFeed().models)
		} catch {
			XCTAssertEqual(error as NSError?, expectedError, file: file, line: line)
		}
    }
}
