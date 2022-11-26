//
//  LoadImageCommentUsecaseTests.swift
//  EssentialFeedTests
//
//  Created by Viral on 26/11/22.
//
import XCTest
import EssentialFeed

class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {

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

    func test_load_deliversErrorOnNon2xxHTTPError() {
        let (sut, client) = makeSUT()
        let samples = [199, 195, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                let jsonData = makeItemJson([])
                client.complete(withStatus: code, data: jsonData, at: index)
            }
        }

    }

    func test_load_deliversErrorOn2xxHTTPResponseWithInvalidJson() {
        let (sut, client) = makeSUT()

        let samples = [200, 201, 205, 280, 299]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                let invalidJsonData = Data("invalid Json".utf8)
                client.complete(withStatus: code, data: invalidJsonData, at: index)
            }
        }
    }

    func test_load_deliversNoItemsOn2xxHTTPResponseWithEmptyJsonList() {
        let (sut, client) = makeSUT()

        let samples = [200, 201, 205, 280, 299]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success([])) {
                let emptyJsonData = makeItemJson([])
                client.complete(withStatus: code, data: emptyJsonData, at: index)
            }
        }
    }

    func test_load_deliversItemsOn2xxHTTPResponseWithJsonList() {
        let (sut, client) = makeSUT()

        let item1 = makeItem(id: UUID(),
                             imageURL: URL(string: "https://www.a-url.com")!)

        let item2 = makeItem(id: UUID(),
                             description: "a description",
                             location: "a location",
                             imageURL: URL(string: "https://www.another-url.com")!)

        let items = [item1.model, item2.model]

        let samples = [200, 201, 205, 280, 299]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success(items)) {
                let jsonData = makeItemJson([item1.json, item2.json])
                client.complete(withStatus: code, data: jsonData, at: index)
            }
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

    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentLoader(url: url, client: client)
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

    private func failure(_ error: RemoteImageCommentLoader.Error) -> RemoteImageCommentLoader.Result {
        return .failure(error)
    }

    private func makeItemJson(_ itemJsons: [[String: Any]]) -> Data {
        let json = [ "items": itemJsons]
        return try! JSONSerialization.data(withJSONObject: json)
    }

    private func expect(_ sut: RemoteImageCommentLoader,
                        toCompleteWith expectedResult: RemoteImageCommentLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #filePath, line: UInt = #line) {

        let exp = expectation(description: "Wait for completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
                case let (.success(receivedItems), .success(expectedItems)):
                    XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)

                case let (.failure(receivedError as RemoteImageCommentLoader.Error),
                          .failure(expectedError as RemoteImageCommentLoader.Error)):
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
