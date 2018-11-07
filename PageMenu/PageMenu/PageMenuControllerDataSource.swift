//
//  PageMenuControllerDataSource.swift
//  PageMenu
//
//  Created by Azuma on 2018/11/06.
//  Copyright © 2018 P&D. All rights reserved.
//

import Foundation

@objc public protocol PageMenuControllerDataSource: class {
    func viewControllers(forPageMenuController pageMenuController: PageMenuController) -> [UIViewController]

    func menuTitles(forPageMenuController pageMenuController: PageMenuController) -> [String]

    func defaultPageIndex(forPageMenuController pageMenuController: PageMenuController) -> Int
}
