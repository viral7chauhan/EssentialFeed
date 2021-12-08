//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Viral on 01/12/21.
//

import XCTest
import EssentialFeed


class RemoteFeedLoaderTest: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-another-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-another-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        sut.load { _ in }
        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { error in
            capturedErrors.append(error)
        }
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)

        XCTAssertEqual(capturedErrors, [.connectivity])
    }

    func test_load_deliversErrorOnNon200HTTPError() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 400, 500]
        samples.enumerated().forEach { index, code in
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load { error in
                capturedErrors.append(error)
            }

            client.complete(withStatus: code, at: index)

            XCTAssertEqual(capturedErrors, [.invalidData])
        }

    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJson() {
        let (sut, client) = makeSUT()


        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { error in
            capturedErrors.append(error)
        }

        let invalidJsonData = Data(bytes: "invalid Json".utf8)
        client.complete(withStatus: 200, data: invalidJsonData)

        XCTAssertEqual(capturedErrors, [.invalidData])


    }

    // MARK: - helper

    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }

    private class HTTPClientSpy: HTTPClient {

        var requestedURLs: [URL] {
            messages.map { $0.url }
        }

        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }

        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }

        func complete(withStatus code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}
