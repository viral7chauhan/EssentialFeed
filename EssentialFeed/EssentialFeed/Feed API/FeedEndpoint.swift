//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by Viral on 25/12/22.
//

import Foundation
public enum FeedEndpoint {
    case get

    public func url(baseURL: URL) -> URL {
        switch self {
            case .get:
                if #available(macOS 13.0, *) {
                    return baseURL.appending(path: "/v1/feed")
                } else {
                    return baseURL.appendingPathComponent("/v1/feed")
                }
        }
    }
}
