//
//  InMemoryFeedStore.swift
//  EssentialAppTests
//
//  Created by Viral on 02/11/22.
//

import Foundation
import EssentialFeed

final class InMemoryFeedStore: FeedStore, FeedImageDataStore {
    private(set) var feedCache: CachedFeed?
    private var feedImageDataCache: [URL: Data] = [:]

    init(feedCache: CachedFeed? = nil) {
        self.feedCache = feedCache
    }

    func deleteCacheFeed(completion: @escaping DeleteCompletion) {
        feedCache = nil
        completion(.success(()))
    }

    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion) {
        feedCache = CachedFeed(feed: feed, timestamp: timestamp)
        completion(.success(()))
    }

    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(feedCache))
    }

    func insert(_ data: Data, for url: URL) throws {
        feedImageDataCache[url] = data
    }

    func retrieve(dataForURL url: URL) throws -> Data? {
        feedImageDataCache[url]
    }
}

extension InMemoryFeedStore {
    static var empty: InMemoryFeedStore {
        InMemoryFeedStore()
    }

    static var withExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: Date.distantPast))
    }

    static var withNonExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: Date()))
    }
}
