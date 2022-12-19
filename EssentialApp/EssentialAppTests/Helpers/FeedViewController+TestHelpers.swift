//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Viral on 11/05/22.
//

import UIKit
import EssentialFeediOS

extension ListViewController {
    public override func loadViewIfNeeded() {
        super.loadViewIfNeeded()
        tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    }
    
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatorePullToRefresh()
    }

    func simulateErrorViewTap() {
        errorView.simulateTap()
    }

    @discardableResult
    func simulateFeedImageVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }

    @discardableResult
    func simulateFeedImageNotVisible(at row: Int) -> FeedImageCell? {
        let view = simulateFeedImageVisible(at: row)

        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)

        return view
    }

    func renderedFeedImageData(at index: Int) -> Data? {
        return simulateFeedImageVisible(at: index)?.renderedImage
    }

    var errorMessage: String? {
        return errorView.message
    }
    
    var isShowLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }

    func numberOfRenderedFeedImageViews() -> Int {
        tableView.numberOfSections == 0 ? 0 :
            tableView.numberOfRows(inSection: feedImageSection)
    }

    private var feedImageSection: Int {
        return 0
    }

    func feedImageView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedFeedImageViews() > row else {
            return nil
        }
        let source = tableView.dataSource
        let indexPath = IndexPath(row: row, section: feedImageSection)
        return source?.tableView(tableView, cellForRowAt: indexPath)
    }

    func simulateFeedImageViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImageSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }

    func simulateFeedImageViewNotNearVisible(at row: Int) {
        simulateFeedImageViewNearVisible(at: row)

        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImageSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
}
