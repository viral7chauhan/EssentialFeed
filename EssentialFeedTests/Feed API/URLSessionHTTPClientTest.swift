//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Viral on 20/12/21.
//

import XCTest

class URLSessionHTTPClient {

    private var session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }
    }
}


class URLSessionHTTPClientTest: XCTestCase {

    func test_getFromURL_createDataTaskWithURL() {
        let url = URL(string: "https://a-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url)
        XCTAssertEqual(session.receivedURLs, [url])
    }

    private class URLSessionSpy: URLSession {
        var receivedURLs = [URL]()

        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            return URLSessionDataTaskSpy()
        }

    }

    private class URLSessionDataTaskSpy: URLSessionDataTask {

    }
}
