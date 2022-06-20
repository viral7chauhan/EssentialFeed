//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Viral on 20/06/22.
//

import Foundation
import EssentialFeed

final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>:
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
