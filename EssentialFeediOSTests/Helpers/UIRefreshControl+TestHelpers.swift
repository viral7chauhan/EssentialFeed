//
//  UIRefreshControl+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Viral on 11/05/22.
//

import UIKit

extension UIRefreshControl {
    func simulatorePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
