//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Viral on 25/09/22.
//

import XCTest
import EssentialFeed

protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>

    func retrieve(dataForURL: URL, completion: @escaping (Result) -> Void)
}

private class  LocalFeedImageDataLoader {
    private struct Task: FeedImageDataLoaderTask {
        func cancel() {}
    }

    public enum Error: Swift.Error {
        case failed
        case noFound
    }

    private let store: FeedImageDataStore

    init(store: FeedImageDataStore) {
        self.store = store
    }

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void)
    -> FeedImageDataLoaderTask {
        store.retrieve(dataForURL: url) { result in
            completion(result
                .mapError { _ in Error.failed }
                .flatMap { _ in .failure(Error.noFound)})
        }
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

    func test_loadImageDataFromURL_failsOnStoreError() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: failed()) {
            let retrievalError = anyNSError()
            store.complete(with: retrievalError)
        }
    }

    func test_loadImageDataFromURL_deliversNotFoundOnNotFound() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: noFound()) {
            store.complete(with: .none)
        }
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

    private func failed() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.Error.failed)
    }

    private func noFound() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.Error.noFound)
    }

    private func expect(_ sut: LocalFeedImageDataLoader,
                        toCompleteWith expectedResult: FeedImageDataLoader.Result,
                        when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")

        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
                case let (.success(receivedData), .success(expectedData)):
                    XCTAssertEqual(receivedData, expectedData, file: file, line: line)

                case (.failure(let receivedError as LocalFeedImageDataLoader.Error),
                      .failure(let expectedError as LocalFeedImageDataLoader.Error)):
                    XCTAssertEqual(receivedError, expectedError, file: file, line: line)

                default:
                    XCTFail("Expected result \(expectedResult), got \(receivedResult) instead",
                            file: file, line: line)
            }

            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)
    }

    private class StoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case retrieve(dataFor: URL)
        }

        private var completions = [(FeedImageDataStore.Result) -> Void]()
        private(set) var receivedMsg = [Message]()

        func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void) {
            receivedMsg.append(.retrieve(dataFor: url))
            completions.append(completion)
        }

        func complete(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }

        func complete(with data: Data?, at index: Int = 0) {
            completions[index](.success(data))
        }
    }
}
