//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Viral on 13/10/22.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
