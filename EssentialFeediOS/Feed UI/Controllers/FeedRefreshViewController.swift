//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Viral on 11/05/22.
//

import Foundation
import UIKit
import EssentialFeed

final class FeedRefreshViewController: NSObject {

    private(set) lazy var view: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return control
    }()

    private let feedLoader: FeedLoader

    var onRefresh: (([FeedImage]) -> Void)?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    @objc func refresh() {
        view.beginRefreshing()
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onRefresh?(feed)

            }
            self?.view.endRefreshing()
        }
    }

}
