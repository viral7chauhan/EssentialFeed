//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Viral on 07/01/22.
//

import Foundation

public protocol FeedStore {
    typealias DeleteCompletion = (Error?) -> Void
    typealias InsertCompletion = (Error?) -> Void

    func deleteCacheFeed(completion: @escaping DeleteCompletion)
    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertCompletion)
}
