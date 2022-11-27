//
//  SharedTestHelper.swift
//  EssentialFeedTests
//
//  Created by Viral on 21/01/22.
//

import Foundation

func anyNSError() -> NSError{
    NSError(domain: "Any Error", code: 1)
}

func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}

func makeItemJson(_ itemJsons: [[String: Any]]) -> Data {
    let json = [ "items": itemJsons]
    return try! JSONSerialization.data(withJSONObject: json)
}

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
