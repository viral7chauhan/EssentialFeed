//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Viral on 17/05/22.
//

import Foundation
import EssentialFeed

protocol FeedView {
    func display(_ feed: [FeedImage])
}

protocol FeedLoadingView {
    func display(isLoading: Bool)
}

final class FeedPresenter {
    typealias Observer<T> = (T) -> Void

    private let feedLoader: FeedLoader

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    var feedView: FeedView?
    var loadingView: FeedLoadingView?

    func loadFeed() {
        loadingView?.display(isLoading: true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(feed)
            }
            self?.loadingView?.display(isLoading: false)
        }
    }
}
