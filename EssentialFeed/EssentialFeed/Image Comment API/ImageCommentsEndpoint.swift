//
//  ImageCommentsEndpoint.swift
//  EssentialFeed
//
//  Created by Viral on 25/12/22.
//

import Foundation

public enum ImageCommentsEndpoint {
    case get(UUID)

    public func url(baseURL: URL) -> URL {
        switch self {
            case let .get(id):
                if #available(macOS 13.0, *) {
                    return baseURL.appending(path: "/v1/image/\(id)/comments")
                } else {
                    return baseURL.appendingPathComponent("/v1/image/\(id)/comments")
                }
        }
    }
}
