//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Viral on 01/12/21.
//

import XCTest
import EssentialFeed


class FeedItemsMapperTests: XCTestCase {

    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let json = makeItemJson([])
        let samples = [199, 201, 400, 500]

        try samples.forEach { code in
            XCTAssertThrowsError(
                try FeedItemsMapper.map(json, response: HTTPURLResponse(statusCode: code))
            )
        }
    }

    func test_map_throwsErrorOn200HTTPResponseWithInvalidJson() {
        let invalidJson = Data("Invalid".utf8)

        XCTAssertThrowsError(
            try FeedItemsMapper.map(invalidJson, response: HTTPURLResponse(statusCode: 200))
        )
    }

    func test_map_deliversNoItemsOn2xxHTTPResponseWithEmptyJsonList() throws {
        let emptyListJson = makeItemJson([])

        let result = try FeedItemsMapper.map(emptyListJson, response: HTTPURLResponse(statusCode: 200))
        XCTAssertEqual(result, [])
    }

    func test_load_deliversItemsOn200HTTPResponseWithJsonItems() throws {

        let item1 = makeItem(id: UUID(),
                             imageURL: URL(string: "https://www.a-url.com")!)

        let item2 = makeItem(id: UUID(),
                             description: "a description",
                             location: "a location",
                             imageURL: URL(string: "https://www.another-url.com")!)


        let json = makeItemJson([item1.json, item2.json])
        let result = try FeedItemsMapper.map(json, response: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result, [item1.model, item2.model])
    }

    // MARK: - helper

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
}


