//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Viral on 06/10/22.
//

import Foundation
import EssentialFeed

func anyURL() -> URL {
    URL(string: "http://a-url.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyData() -> Data {
    return Data("anyData".utf8)
}

func uniqueFeed() -> [FeedImage] {
    [FeedImage(id: UUID(), description: nil, location: nil, url: URL(string: "http://any-url.com")!)]
}
