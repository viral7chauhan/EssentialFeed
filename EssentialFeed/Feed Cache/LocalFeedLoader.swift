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

    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.timestamp = currentDate
    }

    public func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCacheFeed { [weak self] error in
            guard let self = self else { return }

            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, with: completion)
            }
        }
    }

    private func cache(_ items: [FeedItem], with completion: @escaping (Error?) -> Void) {
        store.insert(items, timestamp: timestamp()) { [weak self] error in
            guard self != nil else { return }

            completion(error)
        }
    }
}
