//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Viral on 20/12/21.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {

    private var session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}


class URLSessionHTTPClientTest: XCTestCase {

    func test_getFromURL_resumeTaskWithURL() {
        let url = URL(string: "https://a-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        let sut = URLSessionHTTPClient(session: session)
        session.stub(url: url, and: task)
        sut.get(from: url) { _ in }
        XCTAssertEqual(task.resumeCallCount, 1)
    }

    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "https://a-url.com")!
        let session = URLSessionSpy()
        let error = NSError(domain: "Request Error", code: 0)

        let sut = URLSessionHTTPClient(session: session)
        session.stub(url: url, error: error)
        sut.get(from: url) { result in
            switch result {
                case let .failure(receivedError as NSError):
                    XCTAssertEqual(receivedError, error)
                default:
                    XCTFail("Expected failure with error \(error), get \(result) instead")
            }

        }
    }

    private class URLSessionSpy: URLSession {

        private var stubs = [URL: Stub]()

        private struct Stub {
            var task: URLSessionDataTask
            var error: Error?
        }

        func stub(url: URL, and task: URLSessionDataTask = URLSessionDataTaskSpy(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }

        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError()
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }

    }

    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount: Int = 0

        override func resume() {
            resumeCallCount += 1
        }
    }
}
