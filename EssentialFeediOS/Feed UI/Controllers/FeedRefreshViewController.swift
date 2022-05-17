//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Viral on 11/05/22.
//

import Foundation
import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingView {

    private(set) lazy var view = loadView()

    private let presenter: FeedPresenter

    init(presenter: FeedPresenter) {
        self.presenter = presenter
    }

    @objc func refresh() {
        presenter.loadFeed()
    }

    func display(isLoading: Bool) {
        if isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }

}
