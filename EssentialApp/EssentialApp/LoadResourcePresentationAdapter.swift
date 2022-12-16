//
//  FeedLoaderPresentationAdaapter.swift
//  EssentialFeediOS
//
//  Created by Viral on 20/06/22.
//

import EssentialFeed
import EssentialFeediOS
import Combine

final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
    private let loader: () -> AnyPublisher<Resource, Error>
    private var cancellable: Cancellable?
    var presenter: LoadResourcePresenter<Resource, View>?

    init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }

    func loadResource() {
        presenter?.didStartLoading()
        cancellable = loader()
            .dispatchOnMainQueue()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                        case .finished: break
                            
                        case let .failure(error):
                            self?.presenter?.didFinishLoading(with: error)
                    }
                }, receiveValue: { [weak self] resource in
                    self?.presenter?.didFinishLoading(with: resource)
                })
    }
}

extension LoadResourcePresentationAdapter: FeedViewControllerDelegate {
    func didRequestFeedRefresh() {
        loadResource()
    }
}

extension LoadResourcePresentationAdapter: FeedImageCellControllerDelegate {
    func didRequestImage() {
        loadResource()
    }

    func didCancelImageReques() {
        cancellable?.cancel()
        cancellable = nil
    }
}
