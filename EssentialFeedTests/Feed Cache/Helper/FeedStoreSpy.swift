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
    private var deleteCompletions = [DeleteCompletion]()
    private var insertCompletions = [InsertCompletion]()
    private var retrievalCompletions = [RetrievalCompletion]()

    func deleteCacheFeed(completion: @escaping DeleteCompletion) {
        deleteCompletions.append(completion)
        receivedMsg.append(.deletion)
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        deleteCompletions[index](error)
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
        deleteCompletions[index](nil)
    }

    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion) {
        insertCompletions.append(completion)
        receivedMsg.append(.insert(feed: feed, timestamp: timestamp))
    }

    func retrieve(completion: @escaping RetrievalCompletion) {
        receivedMsg.append(.retrieve)
        retrievalCompletions.append(completion)
    }

    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](error)
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertCompletions[index](error)
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        insertCompletions[index](nil)
    }
}
