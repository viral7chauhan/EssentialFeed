//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Viral on 25/09/22.
//

import XCTest
import EssentialFeed

final class LoadFeedImageDataFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_ ,store) = makeSUT()
        XCTAssertTrue(store.receivedMsg.isEmpty)
    }

    func test_loadImageDataFromURL_requestsStoredDataFromURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()

		_ = try? sut.loadImageData(from: url)

        XCTAssertEqual(store.receivedMsg, [.retrieve(dataFor: url)])

    }

    func test_loadImageDataFromURL_failsOnStoreError() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: failed()) {
            let retrievalError = anyNSError()
            store.completeRetrieval(with: retrievalError)
        }
    }

    func test_loadImageDataFromURL_deliversNotFoundOnNotFound() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: noFound()) {
            store.completeRetrieval(with: .none)
        }
    }

    func test_loadImageDataFromURL_deliversStoredDataOnFoundData() {
        let (sut, store) = makeSUT()
        let foundData = anyData()

        expect(sut, toCompleteWith: .success(foundData)) {
            store.completeRetrieval(with: foundData)
        }
    }

    // MARK: - Helpers

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file,
                         line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func failed() -> Result<Data, Error> {
        return .failure(LocalFeedImageDataLoader.LoadError.failed)
    }

    private func noFound() -> Result<Data, Error> {
        return .failure(LocalFeedImageDataLoader.LoadError.noFound)
    }

    private func never(file: StaticString = #file, line: UInt = #line) {
        XCTFail("Expected no no invocations", file: file, line: line)
    }

    private func expect(_ sut: LocalFeedImageDataLoader,
                        toCompleteWith expectedResult: Result<Data, Error>,
                        when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
		action()
		
		let receivedResult = Result { try sut.loadImageData(from: anyURL()) }
        
		switch (receivedResult, expectedResult) {
			case let (.success(receivedData), .success(expectedData)):
				XCTAssertEqual(receivedData, expectedData, file: file, line: line)

			case (.failure(let receivedError as LocalFeedImageDataLoader.LoadError),
				  .failure(let expectedError as LocalFeedImageDataLoader.LoadError)):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)

			default:
				XCTFail("Expected result \(expectedResult), got \(receivedResult) instead",
						file: file, line: line)
		}
    }
}
