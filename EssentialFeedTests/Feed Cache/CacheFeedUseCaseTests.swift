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

    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = uniqueImageFeed()

        sut.save(items.models) { _ in }

        XCTAssertEqual(store.receivedMsg, [.deletion])
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = uniqueImageFeed()
        let deletionError = anyNSError()

        sut.save(items.models) { _ in }
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.receivedMsg, [.deletion])
    }

    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let items = uniqueImageFeed()

        sut.save(items.models) { _ in }
        store.completeDeletionSuccessfully()

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

    func test_save_doesNotDeliverDeletionErrorOnSUTInstanceDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

        var receivedError = [LocalFeedLoader.SaveResult]()
        sut?.save([uniqueImage()]) { receivedError.append($0) }
        sut = nil

        store.completeDeletion(with: anyNSError())
        XCTAssertTrue(receivedError.isEmpty)
    }

    func test_save_doesNotDeliverInsertionErrorOnSUTInstanceDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

        var receivedError = [LocalFeedLoader.SaveResult]()
        sut?.save([uniqueImage()]) { receivedError.append($0) }

        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        XCTAssertTrue(receivedError.isEmpty)
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
        var receivedError: Error?
        let exp = expectation(description: "Wait for save complete")

        sut.save([uniqueImage()]) { error in
            receivedError = error
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }

    private func uniqueImage() -> FeedImage {
        FeedImage(id: UUID(), description: nil, location: nil, url: anyURL())
    }

    private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let models = [uniqueImage(), uniqueImage()]
        let local = models.map {
            LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        }
        return (models, local)
    }

    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }

    private func anyNSError() -> NSError{
        NSError(domain: "Any Error", code: 1)
    }
}
