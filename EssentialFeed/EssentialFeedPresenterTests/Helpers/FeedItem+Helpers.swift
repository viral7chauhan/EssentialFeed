//
//  FeedItem+Helpers.swift
//  EssentialFeedPresenterTests
//
//  Created by Viral on 10/11/22.
//

import EssentialFeed
import Foundation

func uniqueImage() -> FeedImage {
    FeedImage(id: UUID(), description: nil, location: nil, url: anyURL())
}
