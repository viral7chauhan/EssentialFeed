//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Viral on 16/12/22.
//

import Foundation

public struct ImageCommentsViewModel {
    public let comments: [ImageCommentViewModel]
}

public struct ImageCommentViewModel: Hashable {
    public let message: String
    public let date: String
    public let username: String

    public init(message: String, date: String, username: String) {
        self.message = message
        self.date = date
        self.username = username
    }
}

final public class ImageCommentsPresenter {
    public static var title: String {
        NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
                          tableName: "ImageComments",
                          bundle: Bundle(for: Self.self),
                          comment: "Title for the image comments view")
    }

    public static func map(_ comments: [ImageComment],
                           currentDate: Date = Date(),
                           calender: Calendar = .current,
                           locale: Locale = .current) -> ImageCommentsViewModel {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = locale
        formatter.calendar = calender

        return ImageCommentsViewModel(comments: comments.map {
            ImageCommentViewModel(
                message: $0.message,
                date: formatter.localizedString(for: $0.createdAt, relativeTo: currentDate),
                username: $0.username)
        })
    }
}
