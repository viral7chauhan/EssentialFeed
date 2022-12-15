//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Viral on 15/12/22.
//

import Foundation


public protocol ResourceView {
    func display(_ viewModel: String)
}


public final class LoadResourcePresenter {
    public typealias Mapper = (String) -> String

    private var errorView: FeedErrorView
    private var loadingView: FeedLoadingView
    private var resourceView: ResourceView
    private let mapper: Mapper
    public init(resourceView: ResourceView, loadingView: FeedLoadingView, errorView: FeedErrorView,
                mapper: @escaping Mapper) {
        self.errorView = errorView
        self.loadingView = loadingView
        self.resourceView = resourceView
        self.mapper = mapper
    }

    private var feedLoadError: String {
        return NSLocalizedString(
            "FEED_VIEW_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Error message displayed when we can't load the image feed from the server")
    }

    public func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }

    public func didFinishLoading(with resource: String) {
        resourceView.display(mapper(resource))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }

    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
