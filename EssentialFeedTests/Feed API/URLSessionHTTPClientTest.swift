//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Viral on 20/12/21.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTest: XCTestCase {

    override func tearDown() {
        super.tearDown()

        URLProtocolStub.removeStub()
    }

    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")

        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        makeSUT().get(from: url) { _ in }

        wait(for: [exp], timeout: 2.0)
    }

    func test_getFromURL_failsOnRequestError() {
        let requestedError = anyNSError()

        let receviedError = resultErrorFor((data: nil, response: nil, error: requestedError))

        XCTAssertEqual((receviedError as NSError?)?.domain, requestedError.domain)
        XCTAssertEqual((receviedError as NSError?)?.code, requestedError.code)
    }

    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyURLResponse(), error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyURLResponse(), error: nil)))
    }

    func test_getFromURL_succedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()

        let receivedValue = resultValuesFor((data: data, response: response, error: nil))

        XCTAssertEqual(receivedValue?.data, data)
        XCTAssertEqual(receivedValue?.response?.url, response.url)
        XCTAssertEqual(receivedValue?.response?.statusCode, response.statusCode)

    }

    func test_getFromURL_succedsOnEmptyDataHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse()

        let receviedValue = resultValuesFor((data: nil, response: response, error: nil))
        let emptyData = Data()
        XCTAssertEqual(receviedValue?.data, emptyData)
        XCTAssertEqual(receviedValue?.response?.url, response.url)
        XCTAssertEqual(receviedValue?.response?.statusCode, response.statusCode)

    }

    func test_cancelGetFromURLTask_cancelsURLRequest() {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")

        let task = makeSUT().get(from: url) { result in
            switch result {
                case let .failure(error as NSError) where error.code == URLError.cancelled.rawValue:
                    break

                default:
                    XCTFail("Expected cancelled result, got \(result) instead")
            }
            exp.fulfill()
        }

        task.cancel()
        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helper

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func anyURLResponse() -> URLResponse {
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }

    private func anyHTTPURLResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    private func resultErrorFor(_ values:  (data: Data?, response: URLResponse?, error: Error?)? = nil, taskHandler: (HTTPClientTask) -> Void = { _ in },
                                file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let result = resultFor(values, taskHandler: taskHandler, file: file, line: line)
        switch result {
            case let .failure(error):
                return error

            default:
                XCTFail("Expected failure \(result)", file: file, line: line)
                return nil
        }
    }

    private func resultValuesFor(_ values: (data: Data?, response: URLResponse?, error: Error?),
                                 file: StaticString = #filePath, line: UInt = #line) -> (data :Data?, response: HTTPURLResponse?)? {

        let result = resultFor(values, file: file, line: line)
        switch result {
            case let .success((data, response)):
                return (data, response)

            default:
                XCTFail("Expected failure \(result)", file: file, line: line)
                return nil
        }
    }

    private func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?, taskHandler: (HTTPClientTask) -> Void = { _ in },
                           file: StaticString = #filePath, line: UInt = #line) -> HTTPClient.Result {
        values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }

        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait to request")

        var resultValue: HTTPClient.Result!
        taskHandler(sut.get(from: anyURL()) { result in
            resultValue = result
            exp.fulfill()
        })

        wait(for: [exp], timeout: 1.0)
        return resultValue
    }

    private class URLProtocolStub: URLProtocol {
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
            let requestObserver: ((URLRequest) -> Void)?
        }

        private static var _stub: Stub?
        private static var stub: Stub? {
            get { return queue.sync { _stub } }
            set { queue.sync { _stub = newValue } }
        }

        private static let queue = DispatchQueue(label: "URLProtocolStub.queue")

        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error, requestObserver: nil)
        }

        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            stub = Stub(data: nil, response: nil, error: nil, requestObserver: observer)
        }

        static func removeStub() {
            stub = nil
        }

        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            guard let stub = URLProtocolStub.stub else { return }

            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }

            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }

            stub.requestObserver?(request)
        }

        override func stopLoading() {}
    }

}
