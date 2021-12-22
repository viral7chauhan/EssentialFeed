//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Viral on 20/12/21.
//

import XCTest
import EssentialFeed

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
        let requestedError = anyNSError()

        let receviedError = resultErrorFor(data: nil, response: nil, error: requestedError)

        XCTAssertEqual((receviedError as NSError?)?.domain, requestedError.domain)
        XCTAssertEqual((receviedError as NSError?)?.code, requestedError.code)
    }

    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyURLResponse(), error: nil))
    }

    func test_getFromURL_succedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()

        let receivedValue = resultValuesFor(data: data, response: response, error: nil)

        XCTAssertEqual(receivedValue?.data, data)
        XCTAssertEqual(receivedValue?.response?.url, response.url)
        XCTAssertEqual(receivedValue?.response?.statusCode, response.statusCode)

    }

    func test_getFromURL_succedsOnEmptyDataHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse()

        let receviedValue = resultValuesFor(data: nil, response: response, error: nil)
        let emptyData = Data()
        XCTAssertEqual(receviedValue?.data, emptyData)
        XCTAssertEqual(receviedValue?.response?.url, response.url)
        XCTAssertEqual(receviedValue?.response?.statusCode, response.statusCode)

    }

    // MARK: - Helper

    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func anyNSError() -> NSError{
        NSError(domain: "Any Error", code: 1)
    }

    private func anyData() -> Data {
        "any data".data(using: .utf8)!
    }

    private func anyURLResponse() -> URLResponse {
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }

    private func anyHTTPURLResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?,
                                file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let result = resultFor(data: data, response: response, error: error)
        switch result {
            case let .failure(error):
                return error

            default:
                XCTFail("Expected failure \(result)", file: file, line: line)
                return nil
        }
    }

    private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?,
                                 file: StaticString = #filePath, line: UInt = #line) -> (data :Data?, response: HTTPURLResponse?)? {

        let result = resultFor(data: data, response: response, error: error)
        switch result {
            case let .success(data, response):
                return (data, response)

            default:
                XCTFail("Expected failure \(result)", file: file, line: line)
                return nil
        }
    }

    private func resultFor(data: Data?, response: URLResponse?, error: Error?,
                                 file: StaticString = #filePath, line: UInt = #line) -> HTTPClientResult {
        let sut = makeSUT(file: file, line: line)

        URLProtocolStub.stub(data: data, response: response, error: error)

        let exp = expectation(description: "Wait to request")

        var resultValue: HTTPClientResult!
        sut.get(from: anyURL()) { result in
            resultValue = result
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        return resultValue
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
