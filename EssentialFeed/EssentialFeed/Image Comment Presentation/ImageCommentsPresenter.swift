//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Viral on 16/12/22.
//

import Foundation

final public class ImageCommentsPresenter {
    public static var title: String {
        NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
                          tableName: "ImageComments",
                          bundle: Bundle(for: Self.self),
                          comment: "Title for the image comments view")
    }
}
