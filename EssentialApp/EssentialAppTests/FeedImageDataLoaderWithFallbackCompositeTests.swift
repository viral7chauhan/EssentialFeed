//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Viral on 05/10/22.
//

import XCTest
import EssentialFeed

class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    let primaryLoader: FeedImageDataLoader
    let fallbackLoader: FeedImageDataLoader

    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapper: FeedImageDataLoaderTask?
        func cancel() {
            wrapper?.cancel()
        }
    }

    init(primaryLoader: FeedImageDataLoader, fallbackLoader: FeedImageDataLoader) {
        self.primaryLoader = primaryLoader
        self.fallbackLoader = fallbackLoader
    }

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = TaskWrapper()
        task.wrapper = primaryLoader.loadImageData(from: url) { [weak self] result in
            switch result {
                case .success:
                    completion(result)

                case .failure:
                    task.wrapper = self?.fallbackLoader.loadImageData(from: url,
                                                                      completion: completion)
            }
        }
        return task
    }
}

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {

    func test_init_doesNotLoadImageData() {
        let (_ , primaryLoader, fallbackLoader) = makeSUT()

        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }

    func test_loadImageData_loadsFromPrimaryLoaderFirst() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()

        _ = sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected to load URL from fallback loader")
    }

    func test_loadImageData_loadsFromFallbackbackOnPrimaryLoaderFailure() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()

        _ = sut.loadImageData(from: url) { _ in }

        primaryLoader.complete(with: anyNSError())

        XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
        XCTAssertEqual(fallbackLoader.loadedURLs, [url], "Expected to load URL from fallback loader")
    }

    func test_cancelLoadImageData_cancelsPrimaryLoaderTask() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()

        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()

        XCTAssertEqual(primaryLoader.cancelledURLs, [url], "Expected to cancel URL loading from primary loader")
        XCTAssertTrue(fallbackLoader.cancelledURLs.isEmpty, "Expected no cancelled URLs in the fallback loader")
    }

    func test_cancelLoadImageData_cancelsFallbackLoaderTaskAfterPrimaryLoaderFailure() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()

        let task = sut.loadImageData(from: url) { _ in }
        primaryLoader.complete(with: anyNSError())
        task.cancel()

        XCTAssertTrue(primaryLoader.cancelledURLs.isEmpty, "Expected no cancel URL loading from primary loader")
        XCTAssertEqual(fallbackLoader.cancelledURLs, [url], "Expected to cancelled URLs in the fallback loader")
    }

    func test_loadImageData_deliversPrimaryDataOnPrimaryLoaderSuccess() {
        let (sut, primaryLoader, _) = makeSUT()
        let primaryData = anyData()

        expect(sut, toCompleteWith: .success(primaryData)) {
            primaryLoader.complete(with: primaryData)
        }
    }

    func test_loadImageData_deliversFallbackDataOnFallbackLoaderSuccess() {
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        let fallbackData = anyData()

        expect(sut, toCompleteWith: .success(fallbackData)) {
            primaryLoader.complete(with: anyNSError())
            fallbackLoader.complete(with: fallbackData)
        }
    }

    // MARK: - Helpers
    private func anyURL() -> URL {
        URL(string: "http://a-url.com")!
    }

    private func makeSUT(file: StaticString = #file, line: UInt = #line)
    -> (sut: FeedImageDataLoader, primaryLoader: LoaderSpy, fallbackLoader: LoaderSpy) {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()

        let sut = FeedImageDataLoaderWithFallbackComposite(primaryLoader: primaryLoader,
                                                           fallbackLoader: fallbackLoader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)

        return (sut, primaryLoader, fallbackLoader)
    }

    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }

    private func anyData() -> Data {
        return Data("anyData".utf8)
    }

    private func expect(_ sut: FeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result,
                        when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait to load completion")

        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
                case let (.success(receivedFeed), .success(expectedFeed)):
                    XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)

                case (.failure, .failure):
                    break

                default:
                    XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()

        wait(for: [exp], timeout: 1.0)
    }

    private class LoaderSpy: FeedImageDataLoader {
        private var message = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        private(set) var cancelledURLs = [URL]()

        var loadedURLs: [URL] {
            return message.map { $0.url }
        }

        private struct Task: FeedImageDataLoaderTask {
            let callback: () -> Void
            func cancel() { callback() }
        }

        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void)
        -> FeedImageDataLoaderTask {
            message.append((url, completion))
            return Task { [weak self] in
                self?.cancelledURLs.append(url)
            }
        }

        func complete(with error: Error, at index: Int = 0) {
            message[index].completion(.failure(error))
        }

        func complete(with data: Data, at index: Int = 0) {
            message[index].completion(.success(data))
        }
    }
}
