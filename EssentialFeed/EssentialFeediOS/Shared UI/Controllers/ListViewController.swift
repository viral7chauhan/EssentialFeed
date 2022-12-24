//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Viral on 06/04/22.
//

import UIKit
import EssentialFeed

public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {

    private(set) public var errorView = ErrorView()
    public var onRefresh: (() -> Void)?

    private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
        .init(tableView: tableView) { (tableView, indexPath, controller) -> UITableViewCell? in
            controller.dataSource.tableView(tableView, cellForRowAt: indexPath)
        }
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
        configureErrorView()
        refresh()
    }

    private func configureErrorView() {
        let container = UIView()
        container.backgroundColor = .clear
        container.addSubview(errorView)

        errorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            errorView.topAnchor.constraint(equalTo: container.topAnchor),
            errorView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        tableView.tableHeaderView = container

        errorView.onHide = { [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.sizeTableHeaderToFit()
            self?.tableView.endUpdates()
        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.sizeTableHeaderToFit()
    }

    @IBAction private func refresh() {
        onRefresh?()
    }

    public func display(_ cellControllers: [CellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        snapshot.appendSections([0])
        snapshot.appendItems(cellControllers, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    public func display(_ viewModel: ResourceLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }

    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.message = viewModel.message
    }

    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(at: indexPath)?.prefetch
            dsp?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(at: indexPath)?.prefetch
            dsp?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.tableView?(tableView, didSelectRowAt: indexPath)
    }

    private func cellController(at indexPath: IndexPath) -> CellController? {
        dataSource.itemIdentifier(for: indexPath)
    }
}
