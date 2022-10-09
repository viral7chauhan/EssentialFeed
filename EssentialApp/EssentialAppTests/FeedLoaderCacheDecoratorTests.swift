//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Viral on 10/10/22.
//

import XCTest
import EssentialFeed

final class FeedLoaderCacheDecorator: FeedLoader {
    let decoratee: FeedLoader

    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load(completion: completion)
    }
}

class FeedLoaderCacheDecoratorTests: XCTestCase {

    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let loader = FeedLoaderStub(result: .success(feed))
        let sut = FeedLoaderCacheDecorator(decoratee: loader)

        expect(sut, toCompleteWith: .success(feed))
    }

    func test_laod_deliversErrorOnLoaderFailure() {
        let feedError = anyNSError()
        let loader = FeedLoaderStub(result: .failure(feedError))
        let sut = FeedLoaderCacheDecorator(decoratee: loader)

        expect(sut, toCompleteWith: .failure(feedError))
    }

    // MARK: - Helpers

    private func uniqueFeed() -> [FeedImage] {
        [FeedImage(id: UUID(), description: nil, location: nil, url: URL(string: "http://any-url.com")!)]
    }

    private func expect(_ sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result,
                        file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait to load completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
                case let (.success(receviedFeed), .success(expectedFeed)):
                    XCTAssertEqual(receviedFeed, expectedFeed, file: file, line: line)

                case (.failure, .failure):
                    break

                default:
                    XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
}
