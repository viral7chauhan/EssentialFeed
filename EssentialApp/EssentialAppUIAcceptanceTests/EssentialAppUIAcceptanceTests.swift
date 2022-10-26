//
//  EssentialAppUIAcceptanceTests.swift
//  EssentialAppUIAcceptanceTests
//
//  Created by Viral on 15/10/22.
//

import XCTest

final class EssentialAppUIAcceptanceTests: XCTestCase {

    private let imageCell = "feed-image-cell"
    private let imageView = "feed-image-view"

    func test_onLaunch_displayRemoteFeedWhenCustomerHasConnetivity() {
        let app = XCUIApplication()
        app.launchArguments = ["-reset"]
        app.launch()


        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        expectation(for: NSPredicate(format: "count == 22"), evaluatedWith: feedCells)
        waitForExpectations(timeout: 5)

        let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(firstImage.exists)
    }

    func test_onLaunch_displayCachedRemoteFeedWhenCustomerHasNotConnnectivity() {
        let onlineApp = XCUIApplication()
        onlineApp.launchArguments = ["-reset"]
        onlineApp.launch()
        let feedCells = onlineApp.cells.matching(identifier: "feed-image-cell")
        expectation(for: NSPredicate(format: "count == 22"), evaluatedWith: feedCells)
        waitForExpectations(timeout: 5)

        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-connectivity", "offline"]
        offlineApp.launch()

        let cachedFeedCells = offlineApp.cells.matching(identifier: imageCell)
        XCTAssertEqual(cachedFeedCells.count, 22)

        let firstCachedImage = offlineApp.images.matching(identifier: imageView).firstMatch
        XCTAssertTrue(firstCachedImage.exists)
    }

    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
        let app = XCUIApplication()
        app.launchArguments = ["-reset", "-connectivity", "offline"]
        app.launch()

        let feedCells = app.cells.matching(identifier: imageCell)
        XCTAssertEqual(feedCells.count, 0)
    }
}

