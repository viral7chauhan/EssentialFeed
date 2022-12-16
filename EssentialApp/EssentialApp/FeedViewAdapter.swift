//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Viral on 20/06/22.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: ResourceView {
    private weak var controller: FeedViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher

    init(controller: FeedViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.imageLoader = imageLoader
    }

    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            let adapter = LoadResourcePresentationAdapter<Data, WeakRefVirualProxy<FeedImageCellController>>(loader: { [imageLoader] in
                imageLoader(model.url)
            })

            let view = FeedImageCellController(
                viewModel: FeedImagePresenter.map(model),
                delegate: adapter)
            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirualProxy(view),
                loadingView: WeakRefVirualProxy(view),
                errorView: WeakRefVirualProxy(view),
                mapper: { data in
                    guard let image = UIImage(data: data) else {
                        throw InvalidImageData()
                    }
                    return image
                })

            return view
        })
    }
}

private struct InvalidImageData: Error {}
