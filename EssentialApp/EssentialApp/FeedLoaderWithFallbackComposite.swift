//
//  FeedLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Viral on 05/10/22.
//

import EssentialFeed

public class FeedLoaderWithFallbackComposite: FeedLoader {
    let primaryLoader: FeedLoader
    let fallbackLoader: FeedLoader

    public init(primaryLoader: FeedLoader, fallbackLoader: FeedLoader) {
        self.primaryLoader = primaryLoader
        self.fallbackLoader = fallbackLoader
    }

    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primaryLoader.load { [weak self] result in
            switch result {
                case .success:
                    completion(result)

                case .failure:
                    self?.fallbackLoader.load(completion: completion)
            }

        }
    }
}
