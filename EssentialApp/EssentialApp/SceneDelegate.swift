//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Viral on 04/10/22.
//

import UIKit
import CoreData
import EssentialFeed
import EssentialFeediOS
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()

    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(
            storeURL: NSPersistentContainer
                .defaultDirectoryURL().appending(path: "feed-store.sqlite"))
    }()

    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }

        configureWindow()
    }

    func configureWindow() {
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!

        let remoteFeedLoader = RemoteFeedLoader(url: url, client: httpClient)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)

        let localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
        let localImageLoader = LocalFeedImageDataLoader(store: store)

        window?.rootViewController = UINavigationController(
            rootViewController: FeedUIComposer.feedComposeWith(
                feedLoader: FeedLoaderWithFallbackComposite(
                    primaryLoader: FeedLoaderCacheDecorator(
                        decoratee: remoteFeedLoader,
                        cache: localFeedLoader),
                    fallbackLoader: localFeedLoader),
                imageLoader: FeedImageDataLoaderWithFallbackComposite(
                    primaryLoader: localImageLoader,
                    fallbackLoader: FeedImageDataLoaderCacheDecorator(
                        decoratee: remoteImageLoader,
                        cache: localImageLoader))))
    }
}

