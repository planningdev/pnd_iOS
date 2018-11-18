//
//  PageMenuController.swift
//  PageMenu
//
//  Created by Azuma on 2018/11/06.
//  Copyright © 2018 P&D. All rights reserved.
//

import UIKit

open class PageMenuController: UIViewController {

    public let options: PageMenuOptions

    open weak var dataSource: PageMenuControllerDataSource? {
        didSet {
            self.reloadPages(reloadViewControllers: true)
        }
    }

    open weak var delegate: PageMenuControllerDelegate?

    open internal(set) var viewControllers = [UIViewController]()

    open internal(set) var menuTitles = [String]()

    var currentIndex: Int? {
        guard let vc = self.pageViewController.selectedViewController else { return nil }
        return self.viewControllers.index(of: vc)
    }

    fileprivate lazy var pageViewController: EMPageViewController = {
        let vc = EMPageViewController()

        vc.view.backgroundColor = .clear
        vc.dataSource = self
        vc.delegate = self
        vc.scrollView.backgroundColor = .clear
        if #available(iOS 11.0, *) {
            vc.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            vc.automaticallyAdjustsScrollViewInsets = false
        }

        return vc
    }()

    fileprivate(set) lazy var tabView: TabMenuView = {
        let tabView = TabMenuView(options: self.options)

        tabView.pageItemPressedBlock = { [weak self] (index: Int, direction: EMPageViewControllerNavigationDirection) in
            guard let `self` = self else { return }

            self.displayController(with: index, direction: direction, animated: true)

            self.delegate?.pageMenuController?(self, didSelectMenuItem: index, direction: direction.toPageMenuNavigationDirection)
        }
        return tabView
    }()

    fileprivate var beforeIndex: Int?

    public var tabMenuView: UIView {
        return self.tabView
    }

    public var isInfinite: Bool {
        return self.options.isInfinite
    }

    public var pageCount: Int {
        return self.viewControllers.count
    }

    fileprivate var tabItemCount: Int {
        return self.menuTitles.count
    }

    public init(options: PageMenuOptions? = nil) {
        self.options = options ?? DefaultPageMenuOption()
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented, use init(coder: options:)")
    }

    public init?(coder: NSCoder, options: PageMenuOptions? = nil) {
        self.options = options ?? DefaultPageMenuOption()
        super.init(coder: coder)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let currentIndex = self.currentIndex, self.isInfinite {
            self.tabView.updateCurrentIndex(currentIndex, shouldScroll: true)
        }
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.tabView.layouted = true
    }

    public func reloadPages() {
        self.reloadPages(reloadViewControllers: true)
    }

    public func scrollToNext(animated: Bool, completion: ((Bool) -> Void)?) {
        self.pageViewController.scrollForward(animated: animated, completion: completion)
    }

    public func scrollToPrevious(animated: Bool, completion: ((Bool) -> Void)?) {
        self.pageViewController.scrollReverse(animated: animated, completion: completion)
    }

    fileprivate func displayController(with index: Int, direction: EMPageViewControllerNavigationDirection, animated: Bool) {
        if self.pageViewController.scrolling { return }
        if self.pageViewController.selectedViewController == viewControllers[index] {
            self.tabView.updateCollectionViewUserInteractionEnabled(true)
            return
        }

        self.beforeIndex = index
        self.pageViewController.delegate = nil
        self.tabView.updateCollectionViewUserInteractionEnabled(false)

        let completion: ((Bool) -> Void) = { [weak self] _ in
            guard let `self` = self else { return }

            self.beforeIndex = index
            self.pageViewController.delegate = self
            self.tabView.updateCollectionViewUserInteractionEnabled(true)
            self.delegate?.pageMenuController?(self, didScrollToPageAtIndex: index, direction: direction.toPageMenuNavigationDirection)
        }

        self.delegate?.pageMenuController?(self, willScrollToPageAtIndex: self.currentIndex ?? 0, direction: direction.toPageMenuNavigationDirection)
        self.pageViewController.selectViewController(viewControllers[index], direction: direction, animated: animated, completion: completion)

        guard self.isViewLoaded else { return }

        self.tabView.updateCurrentIndex(index, shouldScroll: true)
    }

    fileprivate func reloadPages(reloadViewControllers: Bool) {
        guard let defaultIndex = self.dataSource?.defaultPageIndex(forPageMenuController: self) else {
            self.tabView.pageTabItems = []
            return
        }

        if self.tabView.superview == nil {
            assertionFailure("TabMenuView needs to add subview before setting dataSource when you use custom menu position")
        }

        if self.beforeIndex == nil {
            self.beforeIndex = 0
        }

        guard let titles = self.dataSource?.menuTitles(forPageMenuController: self), let viewControllers = self.dataSource?.viewControllers(forPageMenuController: self) else { return }

        if defaultIndex < 0 || defaultIndex >= titles.count || defaultIndex >= viewControllers.count { return }

        if reloadViewControllers || self.viewControllers.count == 0 || self.menuTitles.count == 0 {
            self.viewControllers = viewControllers
            self.menuTitles = titles
        }

        if let beforeIndex = self.beforeIndex {
            self.tabView.pageTabItems = titles
            self.tabView.updateCurrentIndex(beforeIndex, shouldScroll: false, animated: false)
        }

        guard defaultIndex < self.viewControllers.count else { return }

        self.pageViewController.selectViewController(self.viewControllers[defaultIndex], direction: .forward, animated: false, completion: nil)
    }

    fileprivate func setup() {
        self.addChild(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)

        self.view.addSubview(self.tabView)

        self.pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.pageViewController.view.topAnchor.constraint(equalTo: self.tabView.bottomAnchor).isActive = true
        self.pageViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.pageViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true

        self.tabView.translatesAutoresizingMaskIntoConstraints = false
        self.tabView.heightAnchor.constraint(equalToConstant: options.menuItemSize.height).isActive = true
        self.tabView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.tabView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true

        switch self.options.layout {
        case .layoutGuide:
            if #available(iOS 11.0, *) {
                self.pageViewController.view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
                self.tabView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
            } else {
                self.pageViewController.view.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor).isActive = true
                self.tabView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
            }
        case .edge:
            self.pageViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            self.tabView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        }

        self.view.sendSubviewToBack(self.pageViewController.view)
        self.pageViewController.didMove(toParent: self)
    }

}

extension PageMenuController: EMPageViewControllerDelegate {

    func em_pageViewController(_ pageViewController: EMPageViewController, isScrollingFrom startingViewController: UIViewController, destinationViewController: UIViewController?, direction: EMPageViewControllerNavigationDirection) {
        self.tabView.updateCollectionViewUserInteractionEnabled(false)
        self.delegate?.pageMenuController?(self, willScrollToPageAtIndex: self.currentIndex ?? 0, direction: direction.toPageMenuNavigationDirection)
    }

    func em_pageViewController(_ pageViewController: EMPageViewController, didFinishScrollingFrom startingViewController: UIViewController?, destinationViewController: UIViewController, direction: EMPageViewControllerNavigationDirection, transitionSuccessful: Bool) {
        if let currentIndex = self.currentIndex, currentIndex < self.tabItemCount {
            self.tabView.updateCurrentIndex(currentIndex, shouldScroll: true)
            self.beforeIndex = currentIndex
            self.delegate?.pageMenuController?(self, didScrollToPageAtIndex: currentIndex, direction: direction.toPageMenuNavigationDirection)
        }

        self.tabView.updateCollectionViewUserInteractionEnabled(true)
    }

    func em_pageViewController(_ pageViewController: EMPageViewController, isScrollingFrom startingViewController: UIViewController, destinationViewController: UIViewController?, direction: EMPageViewControllerNavigationDirection, progress: CGFloat) {
        guard let beforeIndex = self.beforeIndex else { return }
        var index: Int
        if progress > 0 {
            index = beforeIndex + 1
        } else {
            index = beforeIndex - 1
        }

        if index == self.tabItemCount {
            index = 0
        } else if index < 0 {
            index = self.tabItemCount - 1
        }

        let scrollOffsetX = self.view.frame.width * progress
        self.tabView.scrollCurrentBarView(index, contentOffsetX: scrollOffsetX, progress: progress)
        self.delegate?.pageMenuController?(self, scrollingProgress: progress, direction: direction.toPageMenuNavigationDirection)
    }
}

extension PageMenuController: EMPageViewControllerDataSource {

    private func nextViewController(_ viewController: UIViewController, isAfter:Bool) -> UIViewController? {
        guard var index = viewControllers.index(of: viewController) else { return nil }

        if isAfter {
            index += 1
        } else {
            index -= 1
        }

        if self.isInfinite {
            if index < 0 {
                index = viewControllers.count - 1
            } else if index == viewControllers.count {
                index = 0
            }
        }

        if index >= 0 && index < viewControllers.count {
            return viewControllers[index]
        }
        return nil
    }

    func em_pageViewController(_ pageViewController: EMPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        return nextViewController(viewController, isAfter: true)
    }

    func em_pageViewController(_ pageViewController: EMPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        return nextViewController(viewController, isAfter: false)
    }


}
