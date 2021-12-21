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
        session.dataTask(with: url) { _, _, _ in }.resume()
    }
}


class URLSessionHTTPClientTest: XCTestCase {

    func test_getFromURL_resumeTaskWithURL() {
        let url = URL(string: "https://a-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        let sut = URLSessionHTTPClient(session: session)
        session.stub(url: url, and: task)
        sut.get(from: url)
        XCTAssertEqual(task.resumeCallCount, 1)
    }

    private class URLSessionSpy: URLSession {

        private var stubs = [URL: URLSessionDataTask]()

        func stub(url: URL, and task: URLSessionDataTask) {
            stubs[url] = task
        }

        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            return stubs[url] ?? URLSessionDataTaskSpy()
        }

    }

    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount: Int = 0

        override func resume() {
            resumeCallCount += 1
        }
    }
}
