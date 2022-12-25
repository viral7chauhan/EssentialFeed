//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Viral on 25/12/22.
//

import XCTest
import UIKit
import EssentialApp
import EssentialFeed
import EssentialFeediOS
import Combine

final class CommentsUIIntegrationTests: XCTestCase {

    func test_commentsView_hasTitle() {
        let (sut, _) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.title, commentsTitle)
    }

    func test_loadCommentsActions_requestCommentsFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before view is loaded")

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading requests once view is loaded")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected another loading request once user initiated a reload")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected yet another loading request once user initiated another reload")
    }

    func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowLoadingIndicator, "Expected loading indicator once view is loaded")

        loader.completeCommentsLoading(at: 0)
        XCTAssertFalse(sut.isShowLoadingIndicator, "Expected no loading indicator once loading completes successfully")

        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowLoadingIndicator, "Expected loading indicator once user initiated a reload")

        loader.completeCommentsLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }

    func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
        let comment0 = makeComment(message: "a description", username: "a location")
        let comment1 = makeComment(message: "another description", username: "another username")

        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        assertThat(sut: sut, isRendering: [ImageComment]())

        loader.completeCommentsLoading(with : [comment0], at: 0)
        assertThat(sut: sut, isRendering: [comment0])

        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [comment0, comment1], at: 1)
        assertThat(sut: sut, isRendering: [comment0, comment1])
    }

    func test_loadCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
        let comment = makeComment()
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeCommentsLoading(with : [comment], at: 0)
        assertThat(sut: sut, isRendering: [comment])

        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [], at: 1)
        assertThat(sut: sut, isRendering: [ImageComment]())
    }

    func test_loadCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let comment = makeComment()
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeCommentsLoading(with : [comment], at: 0)
        assertThat(sut: sut, isRendering: [comment])

        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoadingWithError(at: 1)
        assertThat(sut: sut, isRendering: [comment])
    }

    func test_loadCommentsCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeCommentsLoading(at: 0)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 2.0)
    }

    func test_loadCommentCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertNil(sut.errorMessage)

        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)

        sut.simulateUserInitiatedReload()
        XCTAssertNil(sut.errorMessage)
    }

    func test_tapOnErrorView_hidesErrorMessage() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertNil(sut.errorMessage)

        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)

        sut.simulateErrorViewTap()
        XCTAssertNil(sut.errorMessage)
    }

    func test_deinit_cancelsRunningRequest() {
        var cancelCallCount = 0
        var sut: ListViewController?

        autoreleasepool {
             sut = CommentsUIComposer.commentsComposeWith {
                PassthroughSubject<[ImageComment], Error>()
                    .handleEvents(receiveCancel:  {
                        cancelCallCount += 1
                    }).eraseToAnyPublisher()
            }
            sut?.loadViewIfNeeded()
        }

        XCTAssertEqual(cancelCallCount, 0)

        sut = nil

        XCTAssertEqual(cancelCallCount, 1)
    }

    // MARK: - Helper

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposeWith(commentsLoader: loader.loadPublisher)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }

    private func makeComment(message: String = "any message", username: String = "any username") -> ImageComment {
        ImageComment(id: UUID(), message: message, createdAt: Date(), username: username)
    }

    private func assertThat(sut: ListViewController, isRendering comments: [ImageComment], file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedComments(), comments.count, "Comments count", file: file, line: line)

        let viewModels = ImageCommentsPresenter.map(comments)

        viewModels.comments.enumerated().forEach { index, comment in
            XCTAssertEqual(sut.commentMessage(at: index), comment.message, "Message at \(index)", file: file,line: line)
            XCTAssertEqual(sut.commentUsername(at: index), comment.username, "Username at \(index)", file: file,line: line)
            XCTAssertEqual(sut.commentDate(at: index), comment.date, "Date at \(index)", file: file,line: line)
        }
    }

    private class LoaderSpy {
        private var requests = [PassthroughSubject<[ImageComment], Error>]()

        var loadCommentsCallCount: Int {
            requests.count
        }

        func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
            let publisher = PassthroughSubject<[ImageComment], Error>()
            requests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }

        func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
            requests[index].send(comments)
        }

        func completeCommentsLoadingWithError(at index: Int) {
            let error = NSError(domain: "an error", code: 0)
            requests[index].send(completion: .failure(error))
        }
    }
}
