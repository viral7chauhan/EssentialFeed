//
//  FeedImageDataLoaderSpy.swift
//  EssentialAppTests
//
//  Created by Viral on 15/10/22.
//

import Foundation
import EssentialFeed

final class FeedImageDataLoaderSpy: FeedImageDataLoader {
    private var message = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
    private(set) var cancelledURLs = [URL]()

    var loadedURLs: [URL] {
        return message.map { $0.url }
    }

    private struct Task: FeedImageDataLoaderTask {
        let callback: () -> Void
        func cancel() { callback() }
    }

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void)
    -> FeedImageDataLoaderTask {
        message.append((url, completion))
        return Task { [weak self] in
            self?.cancelledURLs.append(url)
        }
    }

    func complete(with error: Error, at index: Int = 0) {
        message[index].completion(.failure(error))
    }

    func complete(with data: Data, at index: Int = 0) {
        message[index].completion(.success(data))
    }
}
