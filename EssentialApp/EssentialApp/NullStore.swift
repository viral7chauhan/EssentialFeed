//
//  NullStore.swift
//  EssentialApp
//
//  Created by Viral Chauhan on 30/03/23.
//

import Foundation
import EssentialFeed

final class NullStore: FeedStore {
	func deleteCacheFeed() throws { }
	
	func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {}
	
	func retrieve() throws -> CachedFeed? { .none }
}
extension NullStore: FeedImageDataStore {
	func insert(_ data: Data, for url: URL) throws { }
	
	func retrieve(dataForURL url: URL) throws -> Data? { .none }
}
