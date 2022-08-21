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

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
                case .success: completion(.failure(Error.invalidData))
                case let .failure(error): completion(.failure(error))
            }
        }
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
        private var message = [(url: URL, completion: (HTTPClient.Result) -> Void)]()

        var requestedURLs: [URL] {
            message.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            message.append((url, completion))
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
