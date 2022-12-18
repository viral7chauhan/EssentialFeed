//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Viral on 17/12/22.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

final class ImageCommentsSnapshotTests: XCTestCase {
    
    func test_listWithContent() {
        let sut = makeSUT()

        sut.display(comments())

        assert(snapshot: sut.snapshot(for: .iPhone14(style: .light)), named: "IMAGE_COMMENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .dark)), named: "IMAGE_COMMENT_dark")
    }

    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.tableView.showsHorizontalScrollIndicator = false
        controller.tableView.showsVerticalScrollIndicator = false
        controller.loadViewIfNeeded()
        return controller
    }

    private func comments() -> [CellController] {
        commentCellControllers().map { CellController($0) }
    }

    private func commentCellControllers() -> [ImageCommentCellController] {
        return [
            ImageCommentCellController(
                model: ImageCommentViewModel(message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                                             date: "1000 years ago",
                                             username: "a long long long long long username")),

            ImageCommentCellController(
                model: ImageCommentViewModel(message: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                                             date: "10 days ago",
                                             username: "a  username")),

            ImageCommentCellController(
                model: ImageCommentViewModel(message: "nice",
                                             date: "1 hours ago",
                                             username: "a"))

        ]
    }
}
