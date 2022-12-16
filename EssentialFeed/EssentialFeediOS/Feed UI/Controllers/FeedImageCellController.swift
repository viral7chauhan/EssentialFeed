//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Viral on 11/05/22.
//

import UIKit
import EssentialFeed

public protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageReques()
}

public final class FeedImageCellController: FeedImageView, ResourceView, ResourceLoadingView, ResourceErrorView {

    public typealias ResourceViewModel = UIImage

    private let viewModel: FeedImageViewModel<UIImage>

    private let delegate: FeedImageCellControllerDelegate
    var cell: FeedImageCell?

    public init(viewModel: FeedImageViewModel<UIImage>, delegate: FeedImageCellControllerDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
    }

    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.feedImageView.image = nil
        cell?.onRetry = delegate.didRequestImage
        delegate.didRequestImage()
        return cell!
    }

    func preload() {
        delegate.didRequestImage()
    }

    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageReques()
    }

    public func display(_ viewModel: FeedImageViewModel<UIImage>) { }

    public func display(_ viewModel: ResourceLoadingViewModel) {
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
    }

    public func display(_ viewModel: ResourceErrorViewModel) {
        cell?.feedImageRetryButton.isHidden = viewModel.message == nil
    }

    public func display(_ viewModel: UIImage) {
        cell?.feedImageView.setImageAnimated(viewModel)
    }

    private func releaseCellForReuse() {
        cell = nil
    }
}
