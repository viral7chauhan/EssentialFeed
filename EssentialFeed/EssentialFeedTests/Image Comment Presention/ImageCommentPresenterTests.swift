//
//  ImageCommentPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Viral on 16/12/22.
//

import XCTest
import EssentialFeed

final class ImageCommentPresenterTests: XCTestCase {

    func test_title_isLocalized() {
        XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
    }

    func test_map_createsViewModel() {
        let now = Date()
        let calender = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")

        let comments = [
            ImageComment(id: UUID(),
                         message: "a message",
                         createdAt: now.adding(minutes: -5, calender: calender),
                         username: "a username"),
            ImageComment(id: UUID(),
                         message: "a another message",
                         createdAt: now.adding(days: -1, calender: calender),
                         username: "a another username")
        ]

        let viewModel = ImageCommentsPresenter.map(
            comments,
            currentDate: now,
            calender: calender,
            locale: locale
        )

        XCTAssertEqual(viewModel.comments, [
            ImageCommentViewModel(
                message: "a message",
                date: "5 minutes ago",
                username: "a username"
            ),

            ImageCommentViewModel(
                message: "a another message",
                date: "1 day ago",
                username: "a another username"
            )
        ])
    }

    // MARK: - Helper

    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key \(key) in table \(table)", file: file, line: line)
        }
        return value
    }

}
