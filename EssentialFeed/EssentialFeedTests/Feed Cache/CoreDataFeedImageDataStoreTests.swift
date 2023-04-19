//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by Viral on 01/10/22.
//

import EssentialFeed
import XCTest

class CoreDataFeedImageDataStoreTests: XCTestCase {

    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()

        expect(sut, toCompleteRetrievalWith: notFound(), for: anyURL())
    }

    func test_retrieveImageData_deliversNoFoundWhenStoredDataURLDoesNotMatch() {
        let sut = makeSUT()
        let url = anyURL()
        let nonMatchingURL = URL(string: "http://another-url.com")!

        insert(anyData(), for: url, into: sut)

        expect(sut, toCompleteRetrievalWith: notFound(), for: nonMatchingURL)
    }

    func test_retrieveImageData_deliversFoundDataWhenThereIsAStoredImageDataMatchingURL() {
        let sut = makeSUT()
        let storedData = anyData()
        let matchingURL = URL(string: "http://a-url.com")!

        insert(storedData, for: matchingURL, into: sut)

        expect(sut, toCompleteRetrievalWith: found(storedData), for: matchingURL)
    }

    func test_retrieveImageData_deliversLastInsertedValue() {
        let sut = makeSUT()
        let firstStoredData = Data("first".utf8)
        let lastStoredData = Data("last".utf8)
        let url = anyURL()

        insert(firstStoredData, for: url, into: sut)
        insert(lastStoredData, for: url, into: sut)

        expect(sut, toCompleteRetrievalWith: found(lastStoredData), for: url)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataFeedStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func notFound() -> Result<Data?, Error> {
        return .success(.none)
    }

    private func localImage(url: URL) -> LocalFeedImage {
        return LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
    }

    private func found(_ data: Data) -> Result<Data?, Error> {
        return .success(data)
    }

    private func expect(_ sut: CoreDataFeedStore,
                        toCompleteRetrievalWith expectedResult: Result<Data?, Error>,
                        for url: URL,  file: StaticString = #file, line: UInt = #line) {
		let receivedResult = Result { try sut.retrieve(dataForURL: url) }
		
		switch (receivedResult, expectedResult) {
			case let (.success( receivedData), .success(expectedData)):
				XCTAssertEqual(receivedData, expectedData, file: file, line: line)

			default:
				XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
		}
    }

	private func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #file, line: UInt = #line) {
		let exp = expectation(description: "Wait for cache insertion")
		let image = localImage(url: url)
		sut.insert([image], timestamp: Date()) { result in
			if case let .failure(error) = result {
				XCTFail("Failed to save \(image) with error \(error)", file: file, line: line)
			}
			
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
		
		do {
			try sut.insert(data, for: url)
		} catch {
			XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
		}
	}
}
