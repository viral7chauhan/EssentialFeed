//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Viral on 15/08/22.
//

import Foundation

public final class FeedImagePresenter {
    public static func map(_ image: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            description: image.description,
            location: image.location)
    }
}
