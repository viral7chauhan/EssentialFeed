//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Viral on 11/05/22.
//

import UIKit

protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageReques()
}

final class FeedImageCellController: FeedImageView {
    private let delegate: FeedImageCellControllerDelegate
    var cell: FeedImageCell?

    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }

    func view(in tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell") as! FeedImageCell
        self.cell = cell
        delegate.didRequestImage()
        return cell
    }

    func preload() {
        delegate.didRequestImage()
    }

    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageReques()
    }

    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.feedImageView.image = viewModel.image
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
        cell?.feedImageRetryButton.isHidden = !viewModel.shouldRetry
        cell?.onRetry = delegate.didRequestImage
    }

    private func releaseCellForReuse() {
        cell = nil
    }
}
