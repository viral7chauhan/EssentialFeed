//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Viral on 22/12/21.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private var session: URLSession

    private struct UnexpectedValuesRepresentation: Error {}


    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: url) { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse  {
                    return (data, response)
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        }.resume()
    }
}
