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
    public typealias LoadResult = FeedImageDataLoader.Result

    public enum LoadError: Swift.Error {
        case failed
        case noFound
    }

    private final class LoadImageDataTask: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?

        init(completion: (@escaping (FeedImageDataLoader.Result) -> Void)) {
            self.completion = completion
        }

        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }

        func cancel() {
            preventFurtherCompletion()
        }

        private func preventFurtherCompletion() {
            completion = nil
        }
    }

    public func loadImageData(from url: URL, completion: @escaping (LoadResult) -> Void)
	-> FeedImageDataLoaderTask {
		let task = LoadImageDataTask(completion: completion)
		
		task.complete(
			with: Swift.Result {
				try store.retrieve(dataForURL: url)
			}.mapError { _ in LoadError.failed }
				.flatMap { data in
					data.map { .success($0) } ?? .failure(LoadError.noFound)
				})
		
		return task
	}
}
