//
//  PageMenuControllerDirection.swift
//  PageMenu
//
//  Created by Azuma on 2018/11/06.
//  Copyright © 2018 P&D. All rights reserved.
//

import Foundation

@objc public enum PageMenuNavigationDirection: Int {
    case forward
    case reverse
}

extension EMPageViewControllerNavigationDirection {
    var toPageMenuNavigationDirection: PageMenuNavigationDirection {
        switch self {
        case .forward:
            return .forward
        case .reverse:
            return .reverse
        }
    }
}
