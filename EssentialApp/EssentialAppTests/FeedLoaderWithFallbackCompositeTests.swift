//
//  FeedLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Viral on 05/10/22.
//

import XCTest
import EssentialFeed

class FeedLoaderWithFallbackComposite: FeedLoader {
    let primaryLoader: FeedLoader
    let fallbackLoader: FeedLoader

    init(primaryLoader: FeedLoader, fallbackLoader: FeedLoader) {
        self.primaryLoader = primaryLoader
        self.fallbackLoader = fallbackLoader
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primaryLoader.load { [weak self] result in
            switch result {
                case .success:
                    completion(result)

                case .failure:
                    self?.fallbackLoader.load(completion: completion)
            }

        }
    }
}

final class FeedLoaderWithFallbackCompositeTests: XCTestCase {

    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))

        let exp = expectation(description: "Wait to load completion")
        sut.load { result in
            switch result {
                case let .success(receivedFeed):
                    XCTAssertEqual(receivedFeed, primaryFeed)

                case .failure:
                    XCTFail("Expected successful load feed result, got \(result) instead")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_load_deliversFallbackFeedOnPrimaryLoaderFailure() {
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackFeed))

        let exp = expectation(description: "Wait to load completion")
        sut.load { result in
            switch result {
                case let .success(receivedFeed):
                    XCTAssertEqual(receivedFeed, fallbackFeed)

                case .failure:
                    XCTFail("Expected successful load feed result, got \(result) instead")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helpers
    private func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result,
                         file: StaticString = #file, line: UInt = #line) -> FeedLoaderWithFallbackComposite {
        let primaryLoader = LoaderStub(result: primaryResult)
        let fallbackLoader = LoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposite(
            primaryLoader: primaryLoader,
            fallbackLoader: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }

    private func uniqueFeed() -> [FeedImage] {
        [FeedImage(id: UUID(), description: nil, location: nil, url: URL(string: "http://any-url.com")!)]
    }

    private class LoaderStub: FeedLoader {
        private let result: FeedLoader.Result

        init(result: FeedLoader.Result) {
            self.result = result
        }

        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }


}
