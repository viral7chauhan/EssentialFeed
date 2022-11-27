//
//  RemoteLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Viral on 27/11/22.
//
import XCTest
import EssentialFeed

class RemoteLoaderTests: XCTestCase {

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
        expect(sut, toCompleteWith: failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }

    func test_load_deliversErrorOnNon200HTTPError() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                let jsonData = makeItemJson([])
                client.complete(withStatus: code, data: jsonData, at: index)
            }
        }

    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJson() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: failure(.invalidData)) {
            let invalidJsonData = Data("invalid Json".utf8)
            client.complete(withStatus: 200, data: invalidJsonData)
        }
    }

    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJsonList() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .success([])) {
            let emptyJsonData = makeItemJson([])
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

    func test_load_doesNotDeliveredResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "https://another-url")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)

        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load { capturedResults.append($0) }

        sut = nil
        client.complete(withStatus: 200, data: makeItemJson([]))

        XCTAssertTrue(capturedResults.isEmpty)

    }

    // MARK: - helper

    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteLoader(url: url, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }

    private func makeItem(id: UUID, description: String? = nil, location: String? = nil,
                          imageURL: URL) -> (model: FeedImage, json: [String: Any]) {

        let item = FeedImage(id: id,  description: description, location: location, url: imageURL)

        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues { $0 }

        return (item, json)
    }

    private func failure(_ error: RemoteLoader.Error) -> RemoteLoader.Result {
        return .failure(error)
    }

    private func makeItemJson(_ itemJsons: [[String: Any]]) -> Data {
        let json = [ "items": itemJsons]
        return try! JSONSerialization.data(withJSONObject: json)
    }

    private func expect(_ sut: RemoteLoader,
                        toCompleteWith expectedResult: RemoteLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #filePath, line: UInt = #line) {

        let exp = expectation(description: "Wait for completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
                case let (.success(receivedItems), .success(expectedItems)):
                    XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)

                case let (.failure(receivedError as RemoteLoader.Error),
                          .failure(expectedError as RemoteLoader.Error)):
                    XCTAssertEqual(receivedError, expectedError, file: file, line: line)

                default:
                    XCTFail("Expected \(expectedResult) and received \(receivedResult) not matched", file: file, line: line)
            }
            exp.fulfill()

        }
        action()

        wait(for: [exp], timeout: 3.0)
    }
}
