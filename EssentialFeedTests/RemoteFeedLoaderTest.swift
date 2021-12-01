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

class HTTPClient {
    var requestedURL: URL?
    func get(from url: URL) {
        requestedURL = url
    }
}


class RemoteFeedLoaderTest: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        _ = RemoteFeedLoader(client: client)
        
        XCTAssertNil(client.requestedURL)
    }

//    func test_init_requestDataFromURL() {
//        let client = HTTPClient()
//        let sut = RemoteFeedLoader(client: client)
//        sut.load(form: URL(string: "https://a-url.com")!)
//        XCTAssertNotNil(sut.client, )
//    }

}
