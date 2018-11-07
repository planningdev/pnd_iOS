//
//  PageMenuControllerDelegate.swift
//  PageMenu
//
//  Created by Azuma on 2018/11/06.
//  Copyright © 2018 P&D. All rights reserved.
//

import Foundation

@objc public protocol PageMenuControllerDelegate: class {
    @objc optional func pageMenuController(_ pageMenuController: PageMenuController, willScrollToPageAtIndex index: Int, direction: PageMenuControllerDirection)

    @objc optional func pageMenuController(_ pageMenuController: PageMenuController, scrollingProgress progress: CGFloat, direction: PageMenuControllerDirection)

    @objc optional func pageMenuController(_ pageMenuController: PageMenuController, didScrollToPageAtIndex index: Int, direction: PageMenuControllerDirection)

    @objc optional func pageMenuController(_ pageMenuController: PageMenuController, didScrollMenuItem index: Int, direction: PageMenuControllerDirection)
}
