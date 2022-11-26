//
//  RemoteImageCommentLoader.swift
//  EssentialFeed
//
//  Created by Viral on 26/11/22.
//

import Foundation

public final class RemoteImageCommentLoader {

    private let url: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public typealias Result = Swift.Result<[ImageComment], Swift.Error>

    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }

    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
                case let .success((data, response)):
                    completion(RemoteImageCommentLoader.map(data, from: response))
                case .failure:
                    completion(.failure(Error.connectivity))
            }
        }
    }

    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try ImageCommentsMapper.map(data, response: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}
