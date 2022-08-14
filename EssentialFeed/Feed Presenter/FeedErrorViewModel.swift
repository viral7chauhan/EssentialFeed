//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Viral on 15/08/22.
//

public struct FeedErrorViewModel {
    public var message: String?

    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }

    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
