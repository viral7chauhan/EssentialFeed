//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Viral on 16/08/22.
//

import XCTest
import EssentialFeed

private final class RemoteFeedImageDataLoader {
    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    public enum Error: Swift.Error {
        case invalidData
    }

    private final class HTTPClientTaskWrapper: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?

        var wrapped: HTTPClientTask?

        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }

        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }

        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }

        private func preventFurtherCompletions() {
            completion = nil
        }
    }

    @discardableResult
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
                case let .success((data, response)):
                    if response.statusCode == 200, !data.isEmpty {
                        task.complete(with: .success(data))
                    } else {
                        task.complete(with: .failure(Error.invalidData))
                    }

                case let .failure(error): task.complete(with: .failure(error))
            }
        }
        return task
    }
}

class RemoteFeedImageDataLoaderTests: XCTestCase {
    func test_init_doesNotPerformAnyURLRequests() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_loadImageDataFromURL_requestsDataFromURL() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)

        sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)

        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let clientError = NSError(domain: "a client error", code: 0)

        expect(sut, toCompleteWith: .failure(clientError), when: {
            client.completion(with: clientError, at: 0)
        })
    }

    func test_loadImageDataFromURL_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 400, 500]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                client.complete(withStatus: code, data: anyData(), at: index)
            }
        }
    }

    func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HTTPResponseWithError() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.invalidData)) {
            let emptyData = Data()
            client.complete(withStatus: 200, data: emptyData)
        }
    }

    func test_loadImageDataFromURL_deliversReceivedNonEmptyDataOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("non-empty data".utf8)

        expect(sut, toCompleteWith: .success(nonEmptyData), when: {
            client.complete(withStatus: 200, data: nonEmptyData)
        })
    }

    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHandBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)

        var capturedResults = [FeedImageDataLoader.Result]()
        sut?.loadImageData(from: anyURL()) { capturedResults.append($0) }

        sut = nil
        client.complete(withStatus: 200, data: anyData())

        XCTAssertTrue(capturedResults.isEmpty)
    }

    func test_cancelLoadImageDataURLTask_cancelsClientURLRequests() {
        let (sut, client) = makeSUT()
        let url = anyURL()

        let task = sut.loadImageData(from: url) { _ in }
        XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until task is cancelled")

        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
    }

    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("Non empty".utf8)

        var received = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { received.append($0) }
        task.cancel()

        client.complete(withStatus: 404, data: anyData())
        client.complete(withStatus: 200, data: nonEmptyData)
        client.completion(with: anyNSError())

        XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
    }

    // MARK: - Helper
    private func makeSUT(url: URL = anyURL(), file: StaticString = #filePath, line: UInt = #line)
    -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }

    private func expect(_ sut: RemoteFeedImageDataLoader,
                        toCompleteWith expectedResult: FeedImageDataLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #filePath, line: UInt = #line) {

        let url  = anyURL()
        let exp = expectation(description: "Wait for completion")
        sut.loadImageData(from: url) { receivedResult in
            switch (receivedResult, expectedResult) {
                case let (.success(receivedItems), .success(expectedItems)):
                    XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)

                case let (.failure(receivedError as RemoteFeedImageDataLoader.Error),
                          .failure(expectedError as RemoteFeedImageDataLoader.Error)):
                    XCTAssertEqual(receivedError, expectedError, file: file, line: line)

                case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                    XCTAssertEqual(receivedError, expectedError, file: file, line: line)

                default:
                    XCTFail("Expected \(expectedResult) and received \(receivedResult) not matched", file: file, line: line)
            }
            exp.fulfill()

        }
        action()

        wait(for: [exp], timeout: 3.0)
    }

    private func anyData() -> Data {
        return Data("any data".utf8)
    }

    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        return .failure(error)
    }

    private class HTTPClientSpy: HTTPClient {

        private struct Task: HTTPClientTask {
            let callback: () -> Void
            func cancel() { callback() }
        }

        private var message = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        private(set) var cancelledURLs = [URL]()

        var requestedURLs: [URL] {
            message.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            message.append((url, completion))
            return Task { [weak self] in
                self?.cancelledURLs.append(url)
            }
        }

        func completion(with error: Error, at index: Int = 0) {
            message[index].completion(.failure(error))
        }

        func complete(withStatus code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!

            message[index].completion(.success((data, response)))
        }
    }
}
