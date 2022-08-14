//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Viral on 17/07/22.
//

struct FeedErrorViewModel {
    var message: String?

    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }

    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
