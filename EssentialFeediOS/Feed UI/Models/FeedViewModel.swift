//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Viral on 14/05/22.
//

import Foundation
import EssentialFeed

final class FeedViewModel {
    private let feedLoader: FeedLoader

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    var onChanged: ((FeedViewModel) -> Void)?
    var onFeedLoaded: (([FeedImage]) -> Void)?

    private(set) var isLoading = false {
        didSet { onChanged?(self) }
    }

    func loadFeed() {
        isLoading = true
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoaded?(feed)
            }
            self?.isLoading = false
        }
    }
}
