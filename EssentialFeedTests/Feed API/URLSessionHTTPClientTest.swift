//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Viral on 20/12/21.
//

import XCTest
import EssentialFeed

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

class URLSessionHTTPClient {

    private var session: HTTPSession

    init(session: HTTPSession) {
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
        let session = HTTPSessionSpy()
        let task = HTTPSessionTaskSpy()
        let sut = URLSessionHTTPClient(session: session)
        session.stub(url: url, and: task)
        sut.get(from: url) { _ in }
        XCTAssertEqual(task.resumeCallCount, 1)
    }

    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "https://a-url.com")!
        let session = HTTPSessionSpy()
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

    private class HTTPSessionSpy: HTTPSession {

        private var stubs = [URL: Stub]()

        private struct Stub {
            var task: HTTPSessionTask
            var error: Error?
        }

        func stub(url: URL, and task: HTTPSessionTask = HTTPSessionTaskSpy(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }

        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
            guard let stub = stubs[url] else {
                fatalError()
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }

    }

    private class HTTPSessionTaskSpy: HTTPSessionTask {
        var resumeCallCount: Int = 0

        func resume() {
            resumeCallCount += 1
        }
    }
}
