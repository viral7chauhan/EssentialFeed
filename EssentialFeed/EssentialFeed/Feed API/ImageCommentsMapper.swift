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

        guard response.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }

        return root.items
    }
}
