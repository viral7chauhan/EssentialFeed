//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Viral on 14/08/22.
//

import XCTest

struct FeedErrorViewModel {
    var message: String?

    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
    private var errorView: FeedErrorView

    init(errorView: FeedErrorView) {
        self.errorView = errorView
    }

    func didStartLoadingFeed() {
        errorView.display(.noError)
    }
}

class FeedPresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        let (_ , view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }

    func test_didStartLoadingFeed_displayNoErrorMessage() {
        let (sut, view) = makeSUT()

        sut.didStartLoadingFeed()
        XCTAssertEqual(view.messages, [.display(errorMessage: .none)])
    }

    // MARK: - Helper
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(errorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }

    private class ViewSpy: FeedErrorView {
        enum Message: Equatable {
            case display(errorMessage: String?)
        }

        private(set) var messages = [Message]()

        func display(_ viewModel: FeedErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
    }
}
