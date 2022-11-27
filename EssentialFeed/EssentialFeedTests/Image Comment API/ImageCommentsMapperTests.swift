//
//  LoadImageCommentUsecaseTests.swift
//  EssentialFeedTests
//
//  Created by Viral on 26/11/22.
//
import XCTest
import EssentialFeed

class ImageCommentsMapperTests: XCTestCase {

    func test_map_throwsErrorOnNon2xxHTTPError() throws {
        let samples = [199, 195, 400, 500]

        try samples.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(anyData(), response: HTTPURLResponse(statusCode: code))
            )
        }
    }

    func test_map_throwsErrorOn2xxHTTPResponseWithInvalidJson() throws {
        let invalidData = Data("Invalid".utf8)
        let samples = [200, 201, 205, 280, 299]

        try samples.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(invalidData, response: HTTPURLResponse(statusCode: code))
            )
        }
    }

    func test_map_deliversNoItemsOn2xxHTTPResponseWithEmptyJsonList() throws {
        let emptyListJson = makeItemJson([])

        let samples = [200, 201, 205, 280, 299]

        try samples.forEach { code in
            let result = try ImageCommentsMapper.map(emptyListJson, response: HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, [])
        }
    }

    func test_map_deliversItemsOn2xxHTTPResponseWithJsonItems() throws {
        let item1 = makeItem(id: UUID(),
                             message: "a message",
                             createAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
                             username: "a username")

        let item2 = makeItem(id: UUID(),
                             message: "another message",
                             createAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
                             username: "another username")

        let json = makeItemJson([item1.json, item2.json])
        let samples = [200, 201, 250, 280, 299]

        try samples.forEach { code in
            let result = try ImageCommentsMapper.map(json, response: HTTPURLResponse(statusCode: code))

            XCTAssertEqual(result, [item1.model, item2.model])
        }
    }

    // MARK: - helper

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
}
