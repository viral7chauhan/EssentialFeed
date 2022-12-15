//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Viral on 20/06/22.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import Foundation

final class FeedViewAdapter: ResourceView {
    private weak var controller: FeedViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher

    init(controller: FeedViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.imageLoader = imageLoader
    }

    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            let adapter = FeedImageDataLoaderPresentationAdapter<
                WeakRefVirualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)

            let view = FeedImageCellController(delegate: adapter)
            adapter.presenter = FeedImagePresenter(
                view: WeakRefVirualProxy(view), imageTransformer: UIImage.init)

            return view
        })
    }
}
