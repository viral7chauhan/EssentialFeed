//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by Viral on 25/12/22.
//

import EssentialFeediOS
import EssentialFeed
import UIKit
import Combine

public final class CommentsUIComposer {
    private init() {}

    private typealias CommentsPresentationAdapter =
    LoadResourcePresentationAdapter<[ImageComment], CommentsViewAdapter>

    public static func commentsComposeWith(
       commentsLoader: @escaping () -> AnyPublisher<[ImageComment], Error>) -> ListViewController {

        let presentationAdapter = CommentsPresentationAdapter(loader: commentsLoader)

        let controller = makeCommentsViewController(title: ImageCommentsPresenter.title)
        controller.onRefresh = presentationAdapter.loadResource

        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: CommentsViewAdapter(controller: controller),
            loadingView: WeakRefVirualProxy(controller),
            errorView: WeakRefVirualProxy(controller),
            mapper: { ImageCommentsPresenter.map($0) })

        return controller
    }

    private static func makeCommentsViewController(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.title = title
        return controller
    }
}

final class CommentsViewAdapter: ResourceView {
    private weak var controller: ListViewController?


    init(controller: ListViewController) {
        self.controller = controller
    }

    func display(_ viewModel: ImageCommentsViewModel) {
        controller?.display(viewModel.comments.map { viewModel in
            CellController(id: viewModel, ImageCommentCellController(model: viewModel))
        })
    }
}
