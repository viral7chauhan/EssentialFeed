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

    private var retrievalCompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
	private var insertionResult: Result<Void, Error>?

    private(set) var receivedMsg = [Message]()

    func insert(_ data: Data, for url: URL) throws {
        receivedMsg.append(.insert(data: data, for: url))
		try insertionResult?.get()
    }

    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        receivedMsg.append(.retrieve(dataFor: url))
        retrievalCompletions.append(completion)
    }

    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }

    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionResult = .failure(error)
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionResult = .success(())
    }
}
