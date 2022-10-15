//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Viral on 15/10/22.
//

import Foundation

public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
