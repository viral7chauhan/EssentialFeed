//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Viral on 11/05/22.
//

import Foundation
import EssentialFeed
import UIKit

public final class FeedUIComposer {
    private init() {}

    public static func feedComposeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presenter = FeedPresenter()
        let presenterAdapter = FeedLoaderPresentationAdaapter(presenter: presenter, feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(loadFeed: presenterAdapter.loadFeed)
        let feedController = FeedViewController(refreshController: refreshController)
        presenter.loadingView = WeakRefVirualProxy(refreshController)
        presenter.feedView = FeedViewAdapter(controller: feedController, loader: imageLoader)
        return feedController
    }

    static func adaptFeedToCellController(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                FeedImageCellController(viewModel: FeedImageViewModel(model: model,
                                                                      imageLoader: loader,
                                                                      imageTransformer: UIImage.init))
            }
        }
    }
}

private final class WeakRefVirualProxy<T: AnyObject> {
    private weak var object: T?

    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let loader: FeedImageDataLoader

    init(controller: FeedViewController, loader: FeedImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }

    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
            FeedImageCellController(viewModel: FeedImageViewModel(model: model,
                                                                  imageLoader: loader,
                                                                  imageTransformer: UIImage.init))
        }
    }
}

private final class FeedLoaderPresentationAdaapter {
    private let presenter: FeedPresenter
    private let feedLoader: FeedLoader

    init(presenter: FeedPresenter, feedLoader: FeedLoader) {
        self.presenter = presenter
        self.feedLoader = feedLoader
    }

    func loadFeed() {
        presenter.didStartLoadingFeed()
        feedLoader.load { [weak self] result in
            switch result {
                case let .success(feed):
                    self?.presenter.didFinishLoadingFeed(with: feed)

                case let .failure(error):
                    self?.presenter.didFinishLoadingFeed(with: error)
            }
        }
    }
}
