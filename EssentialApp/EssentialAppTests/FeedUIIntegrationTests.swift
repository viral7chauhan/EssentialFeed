//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Viral on 03/04/22.
//

import XCTest
import UIKit
import EssentialApp
import EssentialFeed
import EssentialFeediOS

final class FeedUIIntegrationTests: XCTestCase {

    func test_feedView_hasTitle() {
        let (sut, _) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.title, feedTitle)
    }

    func test_imageSelection_notifyHandler() {
        let image0 = makeImage()
        let image1 = makeImage()
        var selectedImages = [FeedImage]()
        let (sut, loader) = makeSUT(selection: { selectedImages.append($0) })

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)

        sut.simulateTapOnFeedImage(at: 0)
        XCTAssertEqual(selectedImages, [image0])

        sut.simulateTapOnFeedImage(at: 1)
        XCTAssertEqual(selectedImages, [image0, image1])
    }

    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view is loaded")

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading requests once view is loaded")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request once user initiated a reload")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected yet another loading request once user initiated another reload")
    }

    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowLoadingIndicator, "Expected loading indicator once view is loaded")

        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowLoadingIndicator, "Expected no loading indicator once loading completes successfully")

        sut.simulateUserInitiatedReload()
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

        loader.completeFeedLoading(with : [feedImage0, feedImage1], at: 0)
        assertThat(sut: sut, isRendering: [feedImage0, feedImage1])
		
		sut.simulateLoadMoreFeedAction()
		loader.completeLoadMore(with : [feedImage0, feedImage1, feedImage2, feedImage3], at: 0)
		assertThat(sut: sut, isRendering: [feedImage0, feedImage1, feedImage2, feedImage3])

        sut.simulateUserInitiatedReload()
        loader.completeFeedLoading(with: [feedImage0, feedImage1], at: 1)
        assertThat(sut: sut, isRendering: [feedImage0, feedImage1])
    }

    func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyFeed() {
        let image0 = makeImage()
        let image1 = makeImage()
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with : [image0], at: 0)
        assertThat(sut: sut, isRendering: [image0])
		
		sut.simulateLoadMoreFeedAction()
		loader.completeLoadMore(with : [image0, image1], at: 0)
		assertThat(sut: sut, isRendering: [image0, image1])

        sut.simulateUserInitiatedReload()
        loader.completeFeedLoading(with: [], at: 1)
        assertThat(sut: sut, isRendering: [])
    }

    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage()
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with : [image0], at: 0)
        assertThat(sut: sut, isRendering: [image0])

        sut.simulateUserInitiatedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut: sut, isRendering: [image0])
		
		sut.simulateLoadMoreFeedAction()
		loader.completeLoadMoreWithError(at: 0)
		assertThat(sut: sut, isRendering: [image0])
    }

    func test_loadFeedCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertNil(sut.errorMessage)

        loader.completeFeedLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)

        sut.simulateUserInitiatedReload()
        XCTAssertNil(sut.errorMessage)
    }

    func test_tapOnErrorView_hidesErrorMessage() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertNil(sut.errorMessage)

        loader.completeFeedLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)

        sut.simulateErrorViewTap()
        XCTAssertNil(sut.errorMessage)
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

    func test_feedImageView_cancelImageLoadingWhenNoVisiblwAnymore() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image url requests until image is not visible")

        sut.simulateFeedImageNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected one cancelled image url request once first image is not visible anymore")

        sut.simulateFeedImageNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected two cancelled image url request once second image is also not visible anymore")
    }

    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])

        let view0 = sut.simulateFeedImageVisible(at: 0)
        let view1 = sut.simulateFeedImageVisible(at: 1)

        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator for first view while loading first image")

        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator for second view while loading second image")

        loader.completeImageLoading(at: 0)

        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected no loading indicator state change for second view once first image loading completes successfully")

        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for second view once second image loading completes with error")

    }

    func test_feedImageView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])

        let view0 = sut.simulateFeedImageVisible(at: 0)
        let view1 = sut.simulateFeedImageVisible(at: 1)

        XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")

        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once first image loading completed successfully.")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image state change for second view once first image loading completed successfully")

        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected no state change for first view once second image loading completed successfully")
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view once second image loading completed succssfully.")

    }

    func test_feedImageViewRetryButton_isVisibleOnImageURLLoaderError() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])

        let view0 = sut.simulateFeedImageVisible(at: 0)
        let view1 = sut.simulateFeedImageVisible(at: 1)

        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for  first view while loading first image")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view while loading second image")

        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)

        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view once first image loading completed successfully.")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action state change for second view once first image loading completed successfully")

        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action state change for first view once second image loading completed successfully")
        XCTAssertEqual(view1?.isShowingRetryAction, true, "Expected retry action for second view once second image loading completes with error.")

    }

    func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage()])

        let view = sut.simulateFeedImageVisible(at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, false, "Expected no retry action while loading image")

        let invalidImageData = Data("invalid image data".utf8)
        loader.completeImageLoading(with: invalidImageData, at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, true, "Expected retry action once image loading completes with invalid image data")
    }

    func test_feedImageViewRetryAction_retriesImageLoad() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1])

        let view0 = sut.simulateFeedImageVisible(at: 0)
        let view1 = sut.simulateFeedImageVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected two image URL request for the two visible views")

        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected only two image URL requests before retry action")

        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url], "Expected third imageURL request after first view retry action")

        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url, image1.url], "Expected fourth imageURL request after second view retry action")
    }

    func test_feedImageView_preloadsImageURLWhenNearVisible() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until image is near visible")

        sut.simulateFeedImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request once first image is near visible")

        sut.simulateFeedImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request once second image is near visible")
    }

    func test_feedImageView_reloadsImageURLWhenBecomingVisibleAgain() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1])

        sut.simulateFeedImageBecomingVisibleAgain(at: 0)

        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image0.url], "Expected two image URL request after first view becomes visible again")

        sut.simulateFeedImageBecomingVisibleAgain(at: 1)

        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image0.url, image1.url, image1.url], "Expected two new image URL request after second view becomes visible again")
    }

    func test_feedImageView_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not near visible")

        sut.simulateFeedImageViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected first cancelled image URL request once first image is not near visible anymore")

        sut.simulateFeedImageViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected second cancelled image URL request once second image is not near visible anymore")
    }

    func test_feedImageView_doesNotRenderLoadedImageWhenNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage()])

        let view = sut.simulateFeedImageNotVisible(at: 0)
        loader.completeImageLoading(with: anyImageData())

        XCTAssertNil(view?.renderedImage, "Expected no rendered image when an image load finishes after the view is not visible anymore")
    }

    func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        let exp = expectation(description: "Wait for completion")
        DispatchQueue.global().async {
            loader.completeFeedLoading()
            exp.fulfill()
        }

        wait(for: [exp], timeout: 2.0)
    }

    func test_loadImageDataCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        loader.completeFeedLoading(with: [makeImage()])
        _ = sut.simulateFeedImageVisible(at: 0)

        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeImageLoading(with: self.anyImageData(), at: 0)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 2.0)
    }

    func test_feedImageView_configuresViewCorrectlyWhenCellBecomingVisibleAgain() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage()])

        let view0 = sut.simulateFeedImageBecomingVisibleAgain(at: 0)

        XCTAssertEqual(view0?.renderedImage, nil, "Expected no rendered image when view becomes visible again")
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action when view becomes visible again")
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator when view becomes visible again")

        let imageData = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData, at: 1)

        XCTAssertEqual(view0?.renderedImage, imageData, "Expected rendered image when image loads successfully after view becomes visible again")
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry when image loads successfully after view becomes visible again")
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator when image loads successfully after view becomes visible again")
    }

	// MARK: - Load More methods
	
	func test_loadMoreActions_requestMoreFromLoader() {
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()
		loader.completeFeedLoading()
		
		XCTAssertEqual(loader.loadMoreCallCount, 0, "Expected no request before untile load more action")
		
		sut.simulateLoadMoreFeedAction()
		XCTAssertEqual(loader.loadMoreCallCount, 1, "Expected load more request")
		
		sut.simulateLoadMoreFeedAction()
		XCTAssertEqual(loader.loadMoreCallCount, 1, "Expected no request while loading more")
		
		loader.completeLoadMore(lastPage: false, at: 0)
		sut.simulateLoadMoreFeedAction()
		XCTAssertEqual(loader.loadMoreCallCount, 2, "Expected request after load more completed with more pages")
		
		loader.completeLoadMoreWithError(at: 1)
		sut.simulateLoadMoreFeedAction()
		XCTAssertEqual(loader.loadMoreCallCount, 3, "Expected request after load more failure")
		
		loader.completeLoadMore(lastPage: true, at: 2)
		sut.simulateLoadMoreFeedAction()
		XCTAssertEqual(loader.loadMoreCallCount, 3, "Expected no request after loading all pages")
	}
	
	func test_loadingMoreIndicator_isVisibleWhileLoadingMore() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertFalse(sut.isShowingLoadMoreFeedIndicator, "Expected no loading indicator once view is loaded")
		
		loader.completeFeedLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadMoreFeedIndicator, "Expected no loading indicator once loading completes successfully")
		
		sut.simulateLoadMoreFeedAction()
		XCTAssertTrue(sut.isShowingLoadMoreFeedIndicator, "Expected loading indicator on load more action")
		/*
		loader.completeLoadMore(at: 0)
		XCTAssertFalse(sut.isShowingLoadMoreFeedIndicator, "Expected no loading indicator once user initiated loading completes successfully")

		sut.simulateLoadMoreFeedAction()
		XCTAssertTrue(sut.isShowingLoadMoreFeedIndicator, "Expected loading indicator on second load more action")

		loader.completeLoadMoreWithError(at: 1)
		XCTAssertFalse(sut.isShowingLoadMoreFeedIndicator, "Expected no loading indicator once user initiated loading completes with error") */
	}
	
	func test_loadMoreCompletion_rendersErrorMessageOnError() {
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()
		loader.completeFeedLoading()
		
		sut.simulateLoadMoreFeedAction()
		XCTAssertEqual(sut.loadMoreFeedErrorMessage, nil)
		
		loader.completeLoadMoreWithError()
		XCTAssertEqual(sut.loadMoreFeedErrorMessage, loadError)

		sut.simulateLoadMoreFeedAction()
		XCTAssertEqual(sut.loadMoreFeedErrorMessage, nil)
	}
	
	func test_tapOnLoadMoreErrorView_loadMore() {
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()
		loader.completeFeedLoading()
		
		sut.simulateLoadMoreFeedAction()
		XCTAssertEqual(loader.loadMoreCallCount, 1)
		
		sut.simulateTapOnLoadMoreFeedError()
		XCTAssertEqual(loader.loadMoreCallCount, 1)

		loader.completeLoadMoreWithError()
		sut.simulateTapOnLoadMoreFeedError()
		XCTAssertEqual(loader.loadMoreCallCount, 2)
	}
	
	func test_loadMoreCompletion_dispatchesFromBackgroundToMainThread() {
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()
		loader.completeFeedLoading(with: [makeImage()])
		sut.simulateLoadMoreFeedAction()

		let exp = expectation(description: "Wait for background queue")
		DispatchQueue.global().async {
			loader.completeLoadMore()
			exp.fulfill()
		}

		wait(for: [exp], timeout: 2.0)
	}
    // MARK: - Helper

    private func makeSUT(selection: @escaping (FeedImage) -> Void = { _ in },
        file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.feedComposeWith(
            feedLoader: loader.loadPublisher,
            imageLoader: loader.loadImageDataPublisher,
            selection: selection
        )
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }

    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "https://a-url.com")!) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: url)
    }

    private func anyImageData() -> Data {
        UIImage.make(withColor: .red).pngData()!
    }
}
