//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Viral on 03/04/22.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS

class FeedViewControllerTests: XCTestCase {

    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view is loaded")

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading requests once view is loaded")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request once user initiated a reload")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected yet another loading request once user initiated another reload")
    }

    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowLoadingIndicator, "Expected loading indicator once view is loaded")

        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowLoadingIndicator, "Expected no loading indicator once loading completes successfully")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowLoadingIndicator, "Expected loading indicator once user initiated a reload")

        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }

    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let feedImage0 = makeImage(description: "a description", location: "a location")
        let feedImage1 = makeImage(description: nil, location: "another location")
        let feedImage2 = makeImage(description: "another description", location: nil)
        let feedImage3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        assertThat(sut: sut, isRendering: [])

        loader.completeFeedLoading(with : [feedImage0], at: 0)
        assertThat(sut: sut, isRendering: [feedImage0])

        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [feedImage0, feedImage1, feedImage2, feedImage3], at: 0)
        assertThat(sut: sut, isRendering: [feedImage0, feedImage1, feedImage2, feedImage3])
    }

    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage()
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with : [image0], at: 0)
        assertThat(sut: sut, isRendering: [image0])

        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut: sut, isRendering: [image0])
    }

    func test_feedImageView_loadsImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1])

        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")

        sut.simulateFeedImageVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expectef first image url request once first view becomes visible")

        sut.simulateFeedImageVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expectef second image url request once second view also becomes visible")
    }

    // MARK: - Helper

    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(feedLoader: loader, imageLoader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }

    func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "https://a-url.com")!) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: url)
    }

    func assertThat(sut: FeedViewController, isRendering feed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead.", file: file, line: line)
        }

        feed.enumerated().forEach { index, image in
            assertThat(sut: sut, hasConfiguareFor: image, at: index)
        }
    }

    func assertThat(sut: FeedViewController, hasConfiguareFor image: FeedImage, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.feedImageView(at: index)

        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance, get \(String(describing: view)) instead", file: file, line: line)
        }

        let shouldLocationBeVisible = (image.location != nil)
        XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, "Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image view at index (\(index))", file: file, line: line)

        XCTAssertEqual(cell.locationText, image.location, "Expected location text to be \(String(describing: image.location)) for image view at index (\(index))", file: file, line: line)

        XCTAssertEqual(cell.descriptionText, image.description, "Expected description text to be \(String(describing: image.description)) for image view at index (\(index)", file: file, line: line)

    }

    class LoaderSpy: FeedLoader, FeedImageDataLoader {

        // MARK: - FeedLoader

        private var feedRequests = [(FeedLoader.Result) -> Void]()

        var loadFeedCallCount: Int {
            feedRequests.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }

        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index](.success(feed))
        }

        func completeFeedLoadingWithError(at index: Int) {
            let error = NSError(domain: "an error", code: 0)
            feedRequests[index](.failure(error))
        }

        // MARK: - FeedImageDataLoader

        private(set) var loadedImageURLs = [URL]()

        func loadImageData(from url: URL) {
            loadedImageURLs.append(url)
        }
    }
}

private extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatorePullToRefresh()
    }

    func simulateFeedImageVisible(at index: Int) {
        _ = feedImageView(at: index)
    }

    var isShowLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }

    func numberOfRenderedFeedImageViews() -> Int {
        return tableView.numberOfRows(inSection: feedImageSection)
    }

    private var feedImageSection: Int {
        return 0
    }

    func feedImageView(at row: Int) -> UITableViewCell? {
        let source = tableView.dataSource
        let indexPath = IndexPath(row: row, section: feedImageSection)
        return source?.tableView(tableView, cellForRowAt: indexPath)
    }
}

private extension FeedImageCell {
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }

    var locationText: String? {
        return locationLabel.text
    }

    var descriptionText: String? {
        return descriptionLabel.text
    }
}

extension UIRefreshControl {
    func simulatorePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({
                (target as NSObject).perform(Selector($0))
            })
        }
    }
}
