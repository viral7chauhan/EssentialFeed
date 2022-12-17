//
//  SceneDelegateTests.swift
//  EssentialAppTests
//
//  Created by Viral on 31/10/22.
//

import XCTest
import EssentialFeediOS
@testable import EssentialApp

class SceneDelegateTests: XCTestCase {

    func test_configureWindow_setsWindowAsKeyAndVisible() {
        let window = UIWindowSpy()
        let sut = SceneDelegate()
        sut.window = window

        sut.configureWindow()

        XCTAssertEqual(window.makeKeyAndVisibleCallCount, 1, "Expected to make window key and visible")
    }

    func test_configureWindow_configuresRootViewController() {
        let sut = SceneDelegate()

        sut.window = UIWindow()
        sut.configureWindow()

        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topViewController = rootNavigation?.topViewController

        XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) instead")
        XCTAssertTrue(topViewController is ListViewController, "Expected a Feed controller as top view controller, got \(String(describing: topViewController)) instead")
    }

    // MARK: - helper

    private final class UIWindowSpy: UIWindow {
        var makeKeyAndVisibleCallCount = 0
        override func makeKeyAndVisible() {
            makeKeyAndVisibleCallCount = 1
        }
    }
}
