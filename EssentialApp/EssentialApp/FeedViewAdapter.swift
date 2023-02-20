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
    private let selection: (FeedImage) -> Void

    private typealias ImageDataPresentationAdapter =
        LoadResourcePresentationAdapter<Data, WeakRefVirualProxy<FeedImageCellController>>
    private typealias loadMorePresentationAdapter =
        LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>
    
    init(controller: ListViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
         selection: @escaping (FeedImage) -> Void) {
        self.controller = controller
        self.imageLoader = imageLoader
        self.selection = selection
    }

    func display(_ viewModel: Paginated<FeedImage>) {
        let feed: [CellController] = viewModel.items.map { model in
            let adapter = ImageDataPresentationAdapter(loader: { [imageLoader] in
                imageLoader(model.url)
            })

            let view = FeedImageCellController(
                viewModel: FeedImagePresenter.map(model),
                delegate: adapter,
                selection: { [selection] in
                    selection(model)
                })
            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirualProxy(view),
                loadingView: WeakRefVirualProxy(view),
                errorView: WeakRefVirualProxy(view),
                mapper: UIImage.tryMake)

            return CellController(id: model, view)
        }
        
        guard let loadMorePublisher = viewModel.loadMorePublisher else {
            controller?.display(feed)
            return
        }
        
        let loadMoreAdapter = loadMorePresentationAdapter(loader: loadMorePublisher)
        let loadMore = LoadMoreCellController(callback: loadMoreAdapter.loadResource)
        loadMoreAdapter.presenter = LoadResourcePresenter(
            resourceView: self,
            loadingView: WeakRefVirualProxy(loadMore),
            errorView: WeakRefVirualProxy(loadMore))
        
        let loadMoreSection = [CellController(id: UUID(), loadMore)]
        controller?.display(feed, loadMoreSection)
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
