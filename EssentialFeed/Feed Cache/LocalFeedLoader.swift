//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Viral on 07/01/22.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let timestamp: () -> Date

    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult

    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.timestamp = currentDate
    }

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { result in
            switch result {
                case let .failure(error):
                    completion(.failure(error))

                case .empty:
                    completion(.success([]))
                    
                case let .found(feed, _):
                    completion(.success(feed.toModel()))
            }
        }
    }
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCacheFeed { [weak self] error in
            guard let self = self else { return }

            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(feed, with: completion)
            }
        }
    }

    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocal(), timestamp: timestamp()) { [weak self] error in
            guard self != nil else { return }

            completion(error)
        }
    }
}


private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map {
            LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModel() -> [FeedImage] {
        return map {
            FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        }
    }
}
