//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by Viral on 05/09/22.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
