//
//  ImageCommentsMapper.swift
//  EssentialFeed
//
//  Created by Viral on 26/11/22.
//

import Foundation

final class ImageCommentsMapper {

    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    static func map(_ data: Data,
                    response: HTTPURLResponse) throws -> [RemoteFeedItem] {

        guard isOK(response),
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteImageCommentLoader.Error.invalidData
        }

        return root.items
    }

    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        (200...299).contains(response.statusCode)
    }
}
