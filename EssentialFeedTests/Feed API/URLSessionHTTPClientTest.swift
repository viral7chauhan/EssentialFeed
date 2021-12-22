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

    init(session: URLSession = .shared) {
        self.session = session
    }

    private struct UnexpectedValuesRepresentation: Error {}

    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}


class URLSessionHTTPClientTest: XCTestCase {

    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequest()
    }

    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequest()
    }

    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")

        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        makeSUT().get(from: url) { _ in }

        wait(for: [exp], timeout: 2.0)
    }

    func test_getFromURL_failsOnRequestError() {
        let requestedError = NSError(domain: "Request Error", code: 1)

        let receviedError = resultErrorFor(data: nil, response: nil, error: requestedError)
        
        XCTAssertEqual((receviedError as NSError?)?.domain, requestedError.domain)
        XCTAssertEqual((receviedError as NSError?)?.code, requestedError.code)
    }

    func test_getFromURL_failsOnAllNilValues() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
    }

    // MARK: - Helper

    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?,
                                file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let sut = makeSUT(file: file, line: line)

        URLProtocolStub.stub(data: data, response: response, error: error)

        let exp = expectation(description: "Wait to request")

        var resultError: Error?
        sut.get(from: anyURL()) { result in
            switch result {
                case let .failure(error):
                    resultError = error

                default:
                    XCTFail("Expected failure \(result)", file: file, line: line)
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        return resultError
    }

    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?

        private struct Stub {
            var data: Data?
            var response: URLResponse?
            var error: Error?
        }

        static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
            stub = Stub(data: data, response: response, error: error)
        }

        static func startInterceptingRequest() {
            URLProtocol.registerClass(self)
        }

        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(self)
            stub = nil
            requestObserver = nil
        }

        static func observeRequest(_ observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }

        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }

            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }

            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {

        }
    }

}
