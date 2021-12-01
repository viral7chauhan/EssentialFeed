//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Viral on 01/12/21.
//

import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL

    init(url: URL = URL(string: "https://a-url.com")!, client: HTTPClient) {
        self.client = client
        self.url = url
    }

    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    func get(from url: URL) {
        requestedURL = url
    }
}


class RemoteFeedLoaderTest: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(client: client)

        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestDataFromURL() {
        let url = URL(string: "https://a-url.com")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        sut.load()
        XCTAssertEqual(client.requestedURL, url)
    }

}
