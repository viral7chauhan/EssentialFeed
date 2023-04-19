//
//  NullStore.swift
//  EssentialApp
//
//  Created by Viral Chauhan on 30/03/23.
//

import Foundation
import EssentialFeed

final class NullStore: FeedStore & FeedImageDataStore {
	func deleteCacheFeed(completion: @escaping DeleteCompletion) {
		completion(.success(()))
	}
	
	func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion) {
		completion(.success(()))
	}
	
	func retrieve(completion: @escaping RetrievalCompletion) {
		completion(.success(.none))
	}
	
	func insert(_ data: Data, for url: URL) throws { }
	
	func retrieve(dataForURL url: URL) throws -> Data? { .none }
}
