//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Viral on 26/09/22.
//

import Foundation

public final class LocalFeedImageDataLoader {

    private let store: FeedImageDataStore

    public enum Error: Swift.Error {
        case failed
        case noFound
    }

    public init(store: FeedImageDataStore) {
        self.store = store
    }

    private final class Task: FeedImageDataLoaderTask {
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

    public typealias SaveResult = Result<Void, Swift.Error>

    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url) { _ in }
    }

    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void)
    -> FeedImageDataLoaderTask {
        let task = Task(completion: completion)
        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }

            task.complete(with: result
                .mapError { _ in Error.failed }
                .flatMap { data in
                    data.map { .success($0) } ?? .failure(Error.noFound)
                })
        }
        return task
    }
}
