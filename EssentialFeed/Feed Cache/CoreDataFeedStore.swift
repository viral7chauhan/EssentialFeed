//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Viral on 01/02/22.
//

import Foundation

public final class CoreDataFeedStore: FeedStore {
    public init() { }
    
    public func deleteCacheFeed(completion: @escaping DeleteCompletion) {

    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion) {
        
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
}
