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

final class CommentsUIIntegrationTests: FeedUIIntegrationTests {

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

    override func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let feedImage0 = makeImage(description: "a description", location: "a location")
        let feedImage1 = makeImage(description: nil, location: "another location")
        let feedImage2 = makeImage(description: "another description", location: nil)
        let feedImage3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        assertThat(sut: sut, isRendering: [])

        loader.completeCommentsLoading(with : [feedImage0], at: 0)
        assertThat(sut: sut, isRendering: [feedImage0])

        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [feedImage0, feedImage1, feedImage2, feedImage3], at: 1)
        assertThat(sut: sut, isRendering: [feedImage0, feedImage1, feedImage2, feedImage3])
    }

    override func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyFeed() {
        let image0 = makeImage()
        let image1 = makeImage()
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeCommentsLoading(with : [image0, image1], at: 0)
        assertThat(sut: sut, isRendering: [image0, image1])

        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [], at: 1)
        assertThat(sut: sut, isRendering: [])
    }

    override func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage()
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeCommentsLoading(with : [image0], at: 0)
        assertThat(sut: sut, isRendering: [image0])

        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoadingWithError(at: 1)
        assertThat(sut: sut, isRendering: [image0])
    }

    override func test_loadFeedCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertNil(sut.errorMessage)

        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)

        sut.simulateUserInitiatedReload()
        XCTAssertNil(sut.errorMessage)
    }

    override func test_tapOnErrorView_hidesErrorMessage() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertNil(sut.errorMessage)

        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)

        sut.simulateErrorViewTap()
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - Helper

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposeWith(commentsLoader: loader.loadPublisher)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }

    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "https://a-url.com")!) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: url)
    }

    private class LoaderSpy {
        private var requests = [PassthroughSubject<[FeedImage], Error>]()

        var loadCommentsCallCount: Int {
            requests.count
        }

        func loadPublisher() -> AnyPublisher<[FeedImage], Error> {
            let publisher = PassthroughSubject<[FeedImage], Error>()
            requests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }

        func completeCommentsLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            requests[index].send(feed)
        }

        func completeCommentsLoadingWithError(at index: Int) {
            let error = NSError(domain: "an error", code: 0)
            requests[index].send(completion: .failure(error))
        }
    }
}
