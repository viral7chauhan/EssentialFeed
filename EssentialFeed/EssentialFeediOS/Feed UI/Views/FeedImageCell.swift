//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Viral on 23/04/22.
//

import Foundation
import UIKit

public final class FeedImageCell: UITableViewCell {
    @IBOutlet private(set) public var locationContainer: UIView!
    @IBOutlet private(set) public var locationLabel: UILabel!
    @IBOutlet private(set) public var descriptionLabel: UILabel!
    @IBOutlet private(set) public var feedImageContainer: UIView!
    @IBOutlet private(set) public var feedImageView: UIImageView!
    @IBOutlet private(set) public var feedImageRetryButton: UIButton!

    @IBAction private func retryButtonTapped() {
        onRetry?()
    }

    var onRetry: (() -> Void)?

}
