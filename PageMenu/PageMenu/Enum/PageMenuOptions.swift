//
//  PageMenuOptions.swift
//  PageMenu
//
//  Created by Azuma on 2018/11/07.
//  Copyright © 2018 P&D. All rights reserved.
//

import UIKit

public enum PageMenuItemSize {
    case fixed(width: CGFloat, height: CGFloat)
    case sizeToFit(minWidth: CGFloat, height: CGFloat)
}

public extension PageMenuItemSize {
    var width: CGFloat {
        switch self {
        case let .fixed(width, _): return width
        case let .sizeToFit(minWidth, _): return minWidth
        }
    }
    var height: CGFloat {
        switch self {
        case let .fixed(_, height): return height
        case let .sizeToFit(_, height): return height
        }
    }
}

public enum PageMenuCursor {
    case underline(barColor: UIColor, height: CGFloat)
    case roundRect(rectColor: UIColor, cornerRadius: CGFloat, height: CGFloat, borderWidth: CGFloat?, borderColor: UIColor?)
}

extension PageMenuCursor {
    var height: CGFloat {
        switch self {
        case let .underline(_, height): return height
        case let .roundRect(_, _, height, _, _): return height
        }
    }
}

public enum PageMenuLayout {
    case layoutGuide
    case edge
}

public protocol PageMenuOptions {
    var isInfinite: Bool { get }
    var font: UIFont { get }
    var menuItemSize: PageMenuItemSize { get }
    var menuItemMargin: CGFloat { get }
    var menuTitleColor: UIColor { get }
    var menuTitleSelectedColor: UIColor { get }
    var menuCursor: PageMenuCursor { get }
    var tabMenuBackgroundColor: UIColor { get }
    var tabMenuContentInset: UIEdgeInsets { get }
    var layout: PageMenuLayout { get }
}

extension PageMenuOptions {
    public var isInfinite: Bool {
        return false
    }
    public var tabMenuContentInset: UIEdgeInsets {
        return .zero
    }
    public var layout: PageMenuLayout {
        return .layoutGuide
    }
}

public struct DefaultPageMenuOption: PageMenuOptions {
    public var font: UIFont {
        return UIFont.systemFont(ofSize: UIFont.systemFontSize)
    }
    public var menuItemSize: PageMenuItemSize {
        return .sizeToFit(minWidth: 80, height: 30)
    }
    public var menuItemMargin: CGFloat {
        return 8
    }
    public var menuTitleColor: UIColor {
        return UIColor(red: 3/255, green: 125/255, blue: 233/255, alpha: 1)
    }
    public var menuTitleSelectedColor: UIColor {
        return .white
    }
    public var menuCursor: PageMenuCursor {
        return .roundRect(rectColor: UIColor(red: 3/255, green: 125/255, blue: 233/255, alpha: 1), cornerRadius: 8, height: 22, borderWidth: nil, borderColor: nil)
    }
    public var tabMenuBackgroundColor: UIColor {
        return .white
    }

    public init() {}
}
