//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Viral on 01/12/21.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: String
}
