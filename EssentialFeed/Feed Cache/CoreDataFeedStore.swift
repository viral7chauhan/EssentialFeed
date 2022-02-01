//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Viral on 01/02/22.
//

import CoreData

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

private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

private class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
}
