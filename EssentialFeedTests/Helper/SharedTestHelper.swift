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
