//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Viral on 06/10/22.
//

import Foundation

func anyURL() -> URL {
    URL(string: "http://a-url.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyData() -> Data {
    return Data("anyData".utf8)
}
