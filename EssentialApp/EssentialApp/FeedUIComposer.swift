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

    public static func feedComposeWith(
        feedLoader: @escaping () -> FeedLoader.Publisher,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher
    ) -> FeedViewController {
            
        let presentationAdapter = FeedLoaderPresentationAdapter(
            feedLoader: { feedLoader().dispatchOnMainQueue() })

        let feedController = makeFeedViewController(
            delegate: presentationAdapter,
            title: FeedPresenter.title)

        presentationAdapter.presenter = FeedPresenter(
            feedView: FeedViewAdapter(
                controller: feedController,
                imageLoader: imageLoader),
            loadingView: WeakRefVirualProxy(feedController),
            errorView: WeakRefVirualProxy(feedController))

        return feedController
    }

    private static func makeFeedViewController(
        delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
            
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}
