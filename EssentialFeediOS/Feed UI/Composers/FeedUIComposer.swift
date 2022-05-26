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
        let presenterAdapter = FeedLoaderPresentationAdaapter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(delegate: presenterAdapter)

        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.refreshController = refreshController

        presenterAdapter.presenter = FeedPresenter(
            feedView: FeedViewAdapter(controller: feedController, loader: imageLoader),
            loadingView: WeakRefVirualProxy(refreshController))

        return feedController
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

extension WeakRefVirualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ model: FeedImageViewModel<UIImage>) {
        object?.display(model)
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
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirualProxy<FeedImageCellController>, UIImage>(model: model, loader: loader)

            let view = FeedImageCellController(delegate: adapter)
            adapter.presenter = FeedImagePresenter(view: WeakRefVirualProxy(view), imageTransformer: UIImage.init)

            return view
        }
    }
}

private final class FeedLoaderPresentationAdaapter: FeedRefreshViewControllerDelegate {
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

private final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>:
    FeedImageCellControllerDelegate where View.Image == Image {
    private let model: FeedImage
    private var task: FeedImageDataLoaderTask?
    private let imageLoader: FeedImageDataLoader

    var presenter: FeedImagePresenter<View, Image>?

    init(model: FeedImage, loader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = loader
    }

    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        let model = self.model
        task = imageLoader.loadImageData(from: model.url, with: { [weak self] result in
            switch result {
                case let .success(data):
                    self?.presenter?.didFinishLoadingImageData(with: data, for: model)

                case let .failure(error):
                    self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        })
    }

    func didCancelImageReques() {
        task?.cancel()
    }

}
