//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Viral on 11/05/22.
//

import EssentialFeediOS
import EssentialFeed
import UIKit
import Combine

public final class FeedUIComposer {
    private init() {}

    private typealias FeedPresentationAdapter =
        LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>

    public static func feedComposeWith(
        feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher
    ) -> ListViewController {
            
        let presentationAdapter = FeedPresentationAdapter(loader: feedLoader)

        let feedController = makeFeedViewController(
            delegate: presentationAdapter,
            title: FeedPresenter.title)

        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedController,
                imageLoader: imageLoader),
            loadingView: WeakRefVirualProxy(feedController),
            errorView: WeakRefVirualProxy(feedController),
            mapper: FeedPresenter.map)

        return feedController
    }

    private static func makeFeedViewController(
        delegate: FeedViewControllerDelegate, title: String) -> ListViewController {
            
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}
