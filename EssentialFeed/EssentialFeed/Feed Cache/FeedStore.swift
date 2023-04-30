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
	
    typealias DeleteResult = Result<Void, Error>
    typealias DeleteCompletion = (DeleteResult) -> Void

    typealias InsertResult = Result<Void, Error>
    typealias InsertCompletion = (InsertResult) -> Void

    typealias RetrievalResult = Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void

	@available (*, deprecated)
    func deleteCacheFeed(completion: @escaping DeleteCompletion)

	@available (*, deprecated)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion)

	@available (*, deprecated)
    func retrieve(completion: @escaping RetrievalCompletion)
}

public extension FeedStore {
	func deleteCacheFeed() throws {
		let group = DispatchGroup()
		group.enter()
		var result: DeleteResult!
		deleteCacheFeed {
			result = $0
			group.leave()
		}
		group.wait()
		return try result.get()
	}
	
	func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
		let group = DispatchGroup()
		group.enter()
		var result: InsertResult!
		insert(feed, timestamp: timestamp) {
			result = $0
			group.leave()
		}
		group.wait()
		return try result.get()
	}
	
	func retrieve() throws -> CachedFeed? {
		let group = DispatchGroup()
		group.enter()
		var result: RetrievalResult!
		retrieve {
			result = $0
			group.leave()
		}
		group.wait()
		return try result.get()
	}
	
	func deleteCacheFeed(completion: @escaping DeleteCompletion) {}
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion){}
	func retrieve(completion: @escaping RetrievalCompletion) {}
}
