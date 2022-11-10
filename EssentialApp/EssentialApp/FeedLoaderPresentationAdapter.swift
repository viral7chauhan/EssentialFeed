//
//  FeedLoaderPresentationAdaapter.swift
//  EssentialFeediOS
//
//  Created by Viral on 20/06/22.
//

import EssentialFeed
import EssentialFeediOS
import EssentialFeedPresenter

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let feedLoader: FeedLoader
    var presenter: FeedPresenter?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        loadFeed()
    }

    private func loadFeed() {
        presenter?.didStartLoadingFeed()
        feedLoader.load { [weak self] result in
            switch result {
                case let .success(feed):
                    self?.presenter?.didFinishLoadingFeed(with: feed)

                case let .failure(error):
                    self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}
