//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Viral on 04/10/22.
//

import UIKit
import CoreData
import EssentialFeed
import Combine

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

    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()

    private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!

    private lazy var navigationController = UINavigationController(
        rootViewController: FeedUIComposer.feedComposeWith(
            feedLoader: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: makeLocalImgeLoaderWithRemoteFallback,
            selection: showComments))

    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        
        configureWindow()
    }

    func configureWindow() {
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache {_ in } 
    }

    private func showComments(for image: FeedImage) {
        let url = ImageCommentsEndpoint.get(image.id).url(baseURL: baseURL)
        let comments = CommentsUIComposer.commentsComposeWith(commentsLoader: makeRemoteCommentsLoader(url: url))
        navigationController.pushViewController(comments, animated: true)
    }

    private func makeRemoteCommentsLoader(url: URL) -> () -> AnyPublisher<[ImageComment], Error> {
        return { [httpClient] in
            return httpClient
                .getPublisher(url: url)
                .tryMap(ImageCommentsMapper.map)
                .eraseToAnyPublisher()
        }
    }

	private func makeRemoteFeedLoader(after: FeedImage? = nil) -> AnyPublisher<[FeedImage], Error> {
		let url = FeedEndpoint.get(after: after).url(baseURL: baseURL)
		
		return httpClient
			.getPublisher(url: url)
			.tryMap(FeedItemsMapper.map)
			.eraseToAnyPublisher()
	}
	
	private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error> {
		makeRemoteFeedLoader()
			.caching(to: localFeedLoader)
			.fallback(to: localFeedLoader.loadPublisher)
			.map(makeFirstPage)
			.eraseToAnyPublisher()
	}
	
	private func makeFirstPage(items: [FeedImage]) -> Paginated<FeedImage> {
		makePage(items: items, last: items.last)
	}
	
	private func makePage(items: [FeedImage], last: FeedImage?) -> Paginated<FeedImage> {
		Paginated(items: items, loadMorePublisher: last.map { last in
			{ self.makeRemoteLoadMoreLoader(items: items, last: last) }
		})
	}

	private func makeRemoteLoadMoreLoader( items: [FeedImage], last: FeedImage?)
	-> AnyPublisher<Paginated<FeedImage>, Error> {
		makeRemoteFeedLoader(after: last)
			.map { newItems in
				return (items + newItems, newItems.last)
			}.map(makePage)
			.caching(to: localFeedLoader)
	}
	
    private func makeLocalImgeLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        let localImageLoader = LocalFeedImageDataLoader(store: store)

        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: { [httpClient] in
                httpClient
                    .getPublisher(url: url)
                    .tryMap(FeedImageDataMapper.map)
                    .caching(to: localImageLoader, using: url)
            })
    }
}
