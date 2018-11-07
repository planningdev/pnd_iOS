//
//  TabMenuItemCursor.swift
//  PageMenu
//
//  Created by Azuma on 2018/11/07.
//  Copyright © 2018 P&D. All rights reserved.
//

import Foundation

protocol TabMenuItemCursor: class {
    var isHidden: Bool { get set }
    func setup(parent: UIView, isInfinite: Bool, options: PageMenuOptions)
    func updateWidth(width: CGFloat)
    func updatePosition(x: CGFloat)
}
