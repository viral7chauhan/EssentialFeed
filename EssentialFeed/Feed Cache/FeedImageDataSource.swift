//
//  FeedImageDataSource.swift
//  EssentialFeed
//
//  Created by Viral on 26/09/22.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>

    typealias InsertionResult = Swift.Result<Void, Error>

    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
    func retrieve(dataForURL: URL, completion: @escaping (Result) -> Void)
}
