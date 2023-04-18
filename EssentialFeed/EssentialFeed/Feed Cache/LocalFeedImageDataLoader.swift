//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Viral on 26/09/22.
//

import Foundation

public final class LocalFeedImageDataLoader {

    private let store: FeedImageDataStore

    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader: FeedImageDataCache {
    public enum SaveError: Error {
        case failed
    }

    public func save(_ data: Data, for url: URL) throws {
		do {
			try store.insert(data, for: url)
		} catch {
			throw SaveError.failed
		}
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    public enum LoadError: Swift.Error {
        case failed
        case noFound
    }

    public func loadImageData(from url: URL) throws -> Data {
		do {
			if let imageData = try store.retrieve(dataForURL: url) {
				return imageData
			}
		} catch {
			throw LoadError.failed
		}
		throw LoadError.noFound
	}
}
