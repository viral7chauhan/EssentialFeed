//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Viral on 04/10/22.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!

        let remoteClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let remoteFeedLoader = RemoteFeedLoader(url: url, client: remoteClient)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)

        let localStoreURL = NSPersistentContainer
            .defaultDirectoryURL()
            .appendingPathComponent("feed-store.sqlite")

        let localStore = try! CoreDataFeedStore(storeURL: localStoreURL)
        let localFeedLoader = LocalFeedLoader(store: localStore, currentDate: Date.init)
        let localImageLoader = LocalFeedImageDataLoader(store: localStore)

        let feedLoaderFallbackComposition = FeedLoaderWithFallbackComposite(
            primaryLoader: FeedLoaderCacheDecorator(
                decoratee: remoteFeedLoader,
                cache: localFeedLoader),
            fallbackLoader: localFeedLoader)

        let feedImageLoaderFallbackComposition = FeedImageDataLoaderWithFallbackComposite(
            primaryLoader: localImageLoader,
            fallbackLoader: FeedImageDataLoaderCacheDecorator(
                decoratee: remoteImageLoader,
                cache: localImageLoader))

        window?.rootViewController = FeedUIComposer.feedComposeWith(
            feedLoader: feedLoaderFallbackComposition,
            imageLoader: feedImageLoaderFallbackComposition)
    }
}

