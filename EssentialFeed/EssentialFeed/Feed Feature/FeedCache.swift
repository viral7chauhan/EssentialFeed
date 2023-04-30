//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Viral on 13/10/22.
//

import Foundation

public protocol FeedCache {
    func save(_ feed: [FeedImage]) throws
}
