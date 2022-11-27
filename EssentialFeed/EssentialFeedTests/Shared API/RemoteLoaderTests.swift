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

    func test_load_deliversErrorOnMapperError() {
        let (sut, client) = makeSUT(mapper: { _, _ in
            throw anyNSError()
        })

        expect(sut, toCompleteWith: failure(.invalidData)) {
            client.complete(withStatus: 200, data: anyData())
        }
    }

    func test_load_deliversMappedResource() {
        let resource = "a resource"
        let (sut, client) = makeSUT { data, _ in
            String(data: data, encoding: .utf8)!
        }

        expect(sut, toCompleteWith: .success(resource)) {
            client.complete(withStatus: 200, data: Data(resource.utf8))
        }
    }

    func test_load_doesNotDeliveredResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "https://another-url")!
        let client = HTTPClientSpy()
        var sut: RemoteLoader<String>? = RemoteLoader<String>(url: url, client: client, mapper: { _, _ in "any"})

        var capturedResults = [RemoteLoader<String>.Result]()
        sut?.load { capturedResults.append($0) }

        sut = nil
        client.complete(withStatus: 200, data: makeItemJson([]))

        XCTAssertTrue(capturedResults.isEmpty)

    }

    // MARK: - helper

    private func makeSUT(url: URL = URL(string: "https://a-url.com")!,
                         mapper: @escaping (RemoteLoader<String>.Mapper) = { _, _ in "any"},
                         file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteLoader<String>, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteLoader<String>(url: url, client: client, mapper: mapper)
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

    private func failure(_ error: RemoteLoader<String>.Error) -> RemoteLoader<String>.Result {
        return .failure(error)
    }

    private func makeItemJson(_ itemJsons: [[String: Any]]) -> Data {
        let json = [ "items": itemJsons]
        return try! JSONSerialization.data(withJSONObject: json)
    }

    private func expect(_ sut: RemoteLoader<String>,
                        toCompleteWith expectedResult: RemoteLoader<String>.Result,
                        when action: () -> Void,
                        file: StaticString = #filePath, line: UInt = #line) {

        let exp = expectation(description: "Wait for completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
                case let (.success(receivedItems), .success(expectedItems)):
                    XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)

                case let (.failure(receivedError as RemoteLoader<String>.Error),
                          .failure(expectedError as RemoteLoader<String>.Error)):
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
