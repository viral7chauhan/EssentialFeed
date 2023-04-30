//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Viral on 07/01/22.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
	func deleteCacheFeed() throws
	func insert(_ feed: [LocalFeedImage], timestamp: Date) throws
	func retrieve() throws -> CachedFeed?
}
