//
//  LoadImageCommentUsecaseTests.swift
//  EssentialFeedTests
//
//  Created by Viral on 26/11/22.
//
import XCTest
import EssentialFeed

class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {

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
                             message: "a message",
                             createAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
                             username: "a username")

        let item2 = makeItem(id: UUID(),
                             message: "another message",
                             createAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
                             username: "another username")

        let items = [item1.model, item2.model]

        let samples = [200, 201, 205, 280, 299]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success(items)) {
                let jsonData = makeItemJson([item1.json, item2.json])
                client.complete(withStatus: code, data: jsonData, at: index)
            }
        }

    }
    
    // MARK: - helper

    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentLoader(url: url, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }

    private func makeItem(id: UUID, message: String, createAt: (date: Date, iso8601String: String),
                          username: String) -> (model: ImageComment, json: [String: Any]) {

        let item = ImageComment(id: id, message: message, createdAt: createAt.date, username: username)

        let json: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": createAt.iso8601String,
            "author": [
                "username": username
            ]
        ]

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
