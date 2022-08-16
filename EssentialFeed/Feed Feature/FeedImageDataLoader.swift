//
//  FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Viral on 16/08/22.
//

import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, with completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}