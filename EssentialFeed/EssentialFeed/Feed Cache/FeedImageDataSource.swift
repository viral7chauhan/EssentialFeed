//
//  FeedImageDataSource.swift
//  EssentialFeed
//
//  Created by Viral on 26/09/22.
//

import Foundation

public protocol FeedImageDataStore {
    typealias RetrievalResult = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>

	func insert(_ data: Data, for url: URL) throws
	func retrieve(dataForURL url: URL) throws -> Data?
    
	@available(*, deprecated)
	func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
	
	@available(*, deprecated)
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void)
}

public extension FeedImageDataStore {
	func insert(_ data: Data, for url: URL) throws {
		let group = DispatchGroup()
		var result: InsertionResult!
		group.enter()
		insert(data, for: url) {
			result = $0
			group.leave()
		}
		group.wait()
		return try result.get()
	}
	
	func retrieve(dataForURL url: URL) throws -> Data? {
		let group = DispatchGroup()
		var result: RetrievalResult!
		group.enter()
		retrieve(dataForURL: url) {
			result = $0
			group.leave()
		}
		group.wait()
		return try result.get()
	}
	
	func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {}
	func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void) {}
}
