//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Viral on 16/08/22.
//

public struct FeedImageViewModel {
    public let description: String?
    public let location: String?

    public var hasLocation: Bool {
        return location != nil
    }
}
