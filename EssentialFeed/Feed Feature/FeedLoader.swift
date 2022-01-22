//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Viral on 01/12/21.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
