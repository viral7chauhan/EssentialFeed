//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Viral on 25/09/22.
//

import XCTest
import EssentialFeed

protocol FeedImageDataStore {
    func retrieve(dataForURL: URL)
}

private class  LocalFeedImageDataLoader {
    private struct Task: FeedImageDataLoaderTask {
        func cancel() {}
    }
    private let store: FeedImageDataStore

    init(store: FeedImageDataStore) {
        self.store = store
    }

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void)
    -> FeedImageDataLoaderTask {
        store.retrieve(dataForURL: url)
        return Task()
    }
}

final class LocalFeedImageDataLoaderTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_ ,store) = makeSUT()
        XCTAssertTrue(store.receivedMsg.isEmpty)
    }

    func test_loadImageDataFromURL_requestsStoredDataFromURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()

        _ = sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(store.receivedMsg, [.retrieve(dataFor: url)])

    }
    // MARK: - Helpers

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file,
                         line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: StoreSpy) {
        let store = StoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private class StoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case retrieve(dataFor: URL)
        }

        var receivedMsg = [Message]()

        func retrieve(dataForURL url: URL) {
            receivedMsg.append(.retrieve(dataFor: url))
        }
    }
}
