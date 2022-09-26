//
//  FeedImageDataSource.swift
//  EssentialFeed
//
//  Created by Viral on 26/09/22.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>

    func retrieve(dataForURL: URL, completion: @escaping (Result) -> Void)
}
