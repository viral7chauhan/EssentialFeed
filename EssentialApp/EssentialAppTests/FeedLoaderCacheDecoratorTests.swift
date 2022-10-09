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

class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCases {

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
}
