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
        expect(sut, toCompleteWith: .failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }

    func test_load_deliversErrorOnNon200HTTPError() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(.invalidData)) {
                let jsonData = makeItemJson([])
                client.complete(withStatus: code, data: jsonData, at: index)
            }
        }

    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJson() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .failure(.invalidData)) {
            let invalidJsonData = Data("invalid Json".utf8)
            client.complete(withStatus: 200, data: invalidJsonData)
        }
    }

    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJsonList() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .success([])) {
            let emptyJsonData = Data("{\"items\": []}".utf8)
            client.complete(withStatus: 200, data: emptyJsonData)
        }
    }

    func test_load_deliversItemsOn200HTTPResponseWithJsonList() {
        let (sut, client) = makeSUT()

        let item1 = makeItem(id: UUID(),
                             imageURL: URL(string: "https://www.a-url.com")!)

        let item2 = makeItem(id: UUID(),
                             description: "a description",
                             location: "a location",
                             imageURL: URL(string: "https://www.another-url.com")!)

        let models = [item1.model, item2.model]

        expect(sut, toCompleteWith: .success(models)) {
            let jsonData = makeItemJson([item1.json, item2.json])
            client.complete(withStatus: 200, data: jsonData)
        }

    }

    // MARK: - helper

    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }

    private func makeItem(id: UUID,
                          description: String? = nil,
                          location: String? = nil,
                          imageURL: URL)
    -> (model: FeedItem, json: [String: Any]) {

        let item = FeedItem(id: id,
                            description: description,
                            location: location,
                            imageURL: imageURL)

        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].reduce(into: [String: Any]()) { acc, exp in
            if let value = exp.value {
                acc[exp.key] = value
            }
        }

        return (item, json)
    }

    private func makeItemJson(_ itemJsons: [[String: Any]]) -> Data {
        let json = [ "items": itemJsons]
        return try! JSONSerialization.data(withJSONObject: json)
    }

    private func expect(_ sut: RemoteFeedLoader,
                        toCompleteWith result: RemoteFeedLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #filePath, line: UInt = #line) {

        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0) }
        action()

        XCTAssertEqual(capturedResults, [result], file: file, line: line)
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

        func complete(withStatus code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}
