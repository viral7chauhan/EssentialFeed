//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Viral on 12/01/22.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
	
    enum ReceivedMessage: Equatable {
        case deletion
        case insert(feed: [LocalFeedImage], timestamp: Date)
        case retrieve
    }

    private(set) var receivedMsg = [ReceivedMessage]()
	private var deleteResult: Result<Void, Error>?
	private var insertResult: Result<Void, Error>?
	private var retrievalResult: Result<CachedFeed?, Error>?

	func deleteCacheFeed() throws {
		receivedMsg.append(.deletion)
		try deleteResult?.get()
	}
	
	func completeDeletion(with error: Error, at index: Int = 0) {
		deleteResult = .failure(error)
	}

	func completeDeletionSuccessfully(at index: Int = 0) {
		deleteResult = .success(())
	}
	
	func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
		receivedMsg.append(.insert(feed: feed, timestamp: timestamp))
		try insertResult?.get()
	}
	
	func completeInsertion(with error: Error, at index: Int = 0) {
		insertResult = .failure(error)
	}

	func completeInsertionSuccessfully(at index: Int = 0) {
		insertResult = .success(())
	}
	
	func retrieve() throws -> CachedFeed? {
		receivedMsg.append(.retrieve)
		return try retrievalResult?.get()
	}
	
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalResult = .failure(error)
    }

    func completeRetrieveWithEmptyCache(at index: Int = 0) {
        retrievalResult = .success(.none)
    }

    func completeRetrieve(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retrievalResult = .success(.some((feed: feed, timestamp: timestamp)))
    }
}
