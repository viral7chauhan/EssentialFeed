//
//  FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Viral on 16/08/22.
//

import Foundation

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}
