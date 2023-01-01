//
//  FeedEndpointTests.swift
//  EssentialFeedTests
//
//  Created by Viral on 25/12/22.
//

import XCTest
import EssentialFeed

final class FeedEndpointTests: XCTestCase {

    func test_feed_endpointURL() {
        let baseURL = URL(string: "https://base-url.com")!

        let received = FeedEndpoint.get.url(baseURL: baseURL)
        let expected = URL(string: "https://base-url.com/v1/feed")!

        XCTAssertEqual(received, expected)
    }
}
