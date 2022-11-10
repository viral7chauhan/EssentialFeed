//
//  UIView+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Viral on 10/11/22.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.main.run(until: Date())
    }
}
