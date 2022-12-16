//
//  ResourceErrorViewModel.swift
//  EssentialFeed
//
//  Created by Viral on 15/08/22.
//

public struct ResourceErrorViewModel {
    public var message: String?

    static var noError: ResourceErrorViewModel {
        return ResourceErrorViewModel(message: nil)
    }

    static func error(message: String) -> ResourceErrorViewModel {
        return ResourceErrorViewModel(message: message)
    }
}
