//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Viral on 14/08/22.
//

import XCTest

final class FeedPresenter {
    init(view: Any) {

    }
}

class FeedPresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        let view = ViewSpy()
        _ = FeedPresenter(view: view)
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }

    private class ViewSpy {
        let messages = [Any]()
    }
}
