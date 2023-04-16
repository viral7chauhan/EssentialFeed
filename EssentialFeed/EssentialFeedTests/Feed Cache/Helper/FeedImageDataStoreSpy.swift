//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Viral on 27/09/22.
//

import Foundation
import EssentialFeed

class FeedImageDataStoreSpy: FeedImageDataStore {

    enum Message: Equatable {
        case insert(data: Data, for: URL)
        case retrieve(dataFor: URL)
    }

	private var retrievalResult: Result<Data?, Error>?
	private var insertionResult: Result<Void, Error>?

    private(set) var receivedMsg = [Message]()

    func insert(_ data: Data, for url: URL) throws {
        receivedMsg.append(.insert(data: data, for: url))
		try insertionResult?.get()
    }

    func retrieve(dataForURL url: URL) throws -> Data? {
        receivedMsg.append(.retrieve(dataFor: url))
		return try retrievalResult?.get()
    }

    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalResult = .failure(error)
    }

    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalResult = .success(data)
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionResult = .failure(error)
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionResult = .success(())
    }
}
