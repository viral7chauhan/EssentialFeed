//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Viral on 15/08/22.
//

import XCTest

class FeedImagePresenter {
    init(view: Any) {

    }
}

class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotSendMessageToView() {
        let view = ViewSpy()
        _ = FeedImagePresenter(view: view)
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }

    // MARK: - Helper

    private class ViewSpy {
        let messages = [Any]()
    }
}
