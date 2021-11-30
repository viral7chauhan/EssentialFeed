//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Viral on 01/12/21.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
