//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Viral on 15/10/22.
//

import Foundation

public protocol FeedImageDataCache {
    func save(_ data: Data, for url: URL) throws
}
