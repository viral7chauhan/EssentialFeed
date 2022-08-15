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
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }

    // MARK: - Helper
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }

    private class ViewSpy {
        let messages = [Any]()
    }
}
