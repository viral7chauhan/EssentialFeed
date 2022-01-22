//
//  CodableFeedStoreCache.swift
//  EssentialFeedTests
//
//  Created by Viral on 22/01/22.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.empty)
    }
}

class CodableFeedStoreTests: XCTestCase {
    func test_retrieval_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
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
        let sut = CodableFeedStore()
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
}
