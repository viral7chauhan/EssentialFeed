//
//  RemoteImageCommentLoader.swift
//  EssentialFeed
//
//  Created by Viral on 26/11/22.
//

import Foundation

public typealias RemoteImageCommentLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: ImageCommentsMapper.map)
    }
}
