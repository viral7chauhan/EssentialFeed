//
//  CodableFeedStoreCache.swift
//  EssentialFeedTests
//
//  Created by Viral on 22/01/22.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    private struct Cache: Codable {
        let feed: [CacheFeedImage]
        let timestamp: Date

        var localFeed: [LocalFeedImage] {
            feed.map { $0.local }
        }
    }

    private struct CacheFeedImage: Codable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let url: URL

        init(_ image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.url = image.url
        }

        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }


    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")

    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }

    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map(CacheFeedImage.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

class CodableFeedStoreTests: XCTestCase {

    override func setUp() {
        super.setUp()

        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }

    override func tearDown() {
        super.tearDown()

        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }

    func test_retrieval_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for retrieval")

        sut.retrieve { result in
            switch result {
                case .empty:
                    break

                default:
                    XCTFail("Expected empty result, get \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_retrieval_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for retrieval")

        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                    case (.empty,.empty):
                        break

                    default:
                        XCTFail("Expected retrieval twice from empty cache to deliver same result, get firstResult \(firstResult) and secondResult \(secondResult) instead")
                }
                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for retrieval")
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")

            sut.retrieve { retrieveResult in
                switch retrieveResult {
                    case let .found(retrievedFeed, retrievedTimestamp):
                        XCTAssertEqual(retrievedFeed, feed)
                        XCTAssertEqual(retrievedTimestamp, timestamp)
                        break

                    default:
                        XCTFail("Expected found result with feed \(feed) and timestamp \(timestamp). got \(retrieveResult) instead")
                }
                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helper

    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
