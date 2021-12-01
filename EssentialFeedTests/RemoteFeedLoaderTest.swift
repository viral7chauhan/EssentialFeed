//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Viral on 01/12/21.
//

import XCTest

class RemoteFeedLoader {
    let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func load(form url: URL) {
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
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client)
        sut.load(form: URL(string: "https://a-url.com")!)
        XCTAssertNotNil(sut.client)
    }

}
