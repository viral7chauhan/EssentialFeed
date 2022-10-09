//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Viral on 04/10/22.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!

        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        let feedLoader = RemoteFeedLoader(url: url, client: client)
        let imageLoader = RemoteFeedImageDataLoader(client: client)
        window?.rootViewController = FeedUIComposer.feedComposeWith(feedLoader: feedLoader, imageLoader: imageLoader)
    }

}

