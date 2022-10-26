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
        app.launchArguments = ["-reset", "-connectivity", "online"]
        app.launch()

        let feedCells = app.cells.matching(identifier: imageCell)
        XCTAssertEqual(feedCells.count, 2)

        let firstImage = app.images.matching(identifier: imageView).firstMatch
        XCTAssertTrue(firstImage.exists)
    }

    func test_onLaunch_displayCachedRemoteFeedWhenCustomerHasNotConnnectivity() {
        let onlineApp = XCUIApplication()
        onlineApp.launchArguments = ["-reset", "-connectivity", "online"]
        onlineApp.launch()

        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-connectivity", "offline"]
        offlineApp.launch()

        let cachedFeedCells = offlineApp.cells.matching(identifier: imageCell)
        XCTAssertEqual(cachedFeedCells.count, 2)

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

