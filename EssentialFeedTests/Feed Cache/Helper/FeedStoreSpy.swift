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
    }

    private(set) var receivedMsg = [ReceivedMessage]()
    private var deleteCompletions = [DeleteCompletion]()
    private var insertCompletions = [InsertCompletion]()

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

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertCompletions[index](error)
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        insertCompletions[index](nil)
    }
}
