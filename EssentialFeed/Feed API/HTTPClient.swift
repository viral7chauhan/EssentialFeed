//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Viral on 13/12/21.
//

import Foundation

public protocol HTTPClientTask {
    func cancel()
}


public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func get(from url: URL,
             completion: @escaping (Result) -> Void) -> HTTPClientTask
}
