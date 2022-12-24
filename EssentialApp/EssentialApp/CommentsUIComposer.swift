//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by Viral on 25/12/22.
//

import EssentialFeediOS
import EssentialFeed
import UIKit
import Combine

public final class CommentsUIComposer {
    private init() {}

    private typealias FeedPresentationAdapter =
    LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>

    public static func commentsComposeWith(
       commentsLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) -> ListViewController {

        let presentationAdapter = FeedPresentationAdapter(loader: commentsLoader)

        let feedController = makeFeedViewController(title: ImageCommentsPresenter.title)
        feedController.onRefresh = presentationAdapter.loadResource

        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedController,
                imageLoader: { _ in Empty<Data, Error>().eraseToAnyPublisher() } ),
            loadingView: WeakRefVirualProxy(feedController),
            errorView: WeakRefVirualProxy(feedController),
            mapper: FeedPresenter.map)

        return feedController
    }

    private static func makeFeedViewController(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.title = title
        return feedController
    }
}
