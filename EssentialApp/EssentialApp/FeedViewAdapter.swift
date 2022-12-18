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
    private weak var controller: ListViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher

    private typealias ImageDataPresentationAdapter =
        LoadResourcePresentationAdapter<Data, WeakRefVirualProxy<FeedImageCellController>>

    init(controller: ListViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.imageLoader = imageLoader
    }

    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            let adapter = ImageDataPresentationAdapter(loader: { [imageLoader] in
                imageLoader(model.url)
            })

            let view = FeedImageCellController(
                viewModel: FeedImagePresenter.map(model),
                delegate: adapter)
            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirualProxy(view),
                loadingView: WeakRefVirualProxy(view),
                errorView: WeakRefVirualProxy(view),
                mapper: UIImage.tryMake)

            return CellController(view)
        })
    }
}

extension UIImage {

    private struct InvalidImageData: Error {}

    static func tryMake(data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw InvalidImageData()
        }
        return image
    }
}
