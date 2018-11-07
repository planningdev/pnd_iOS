//
//  EMPageViewController.swift
//  PageMenu
//
//  Created by Azuma on 2018/11/07.
//  Copyright © 2018 P&D. All rights reserved.
//

import Foundation

@objc protocol EMPageViewControllerDataSource {
    func em_pageViewController(_ pageViewController: EMPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    func em_pageViewController(_ pageViewController: EMPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
}

@objc protocol EMPageViewControllerDelegate {
    @objc optional func em_pageViewController(_ pageViewController: EMPageViewController, isScrollingFrom startingViewController: UIViewController, destinationViewController: UIViewController?, direction: EMPageViewControllerNavigationDirection)
    @objc optional func em_pageViewController(_ pageViewController: EMPageViewController, isScrollingFrom startingViewController: UIViewController, destinationViewController: UIViewController?, direction: EMPageViewControllerNavigationDirection, progress: CGFloat)
    @objc optional func em_pageViewController(_ pageViewController: EMPageViewController, didFinishScrollingFrom startingViewController: UIViewController?, destinationViewController: UIViewController, direction: EMPageViewControllerNavigationDirection, transitionSuccessful: Bool)
}

@objc enum EMPageViewControllerNavigationDirection: Int {
    case forward
    case reverse
}

class EMPageViewController: UIViewController, UIScrollViewDelegate {
    weak var dataSource: EMPageViewControllerDataSource?
    weak var delegate: EMPageViewControllerDelegate?

    open private(set) lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()

        scrollView.isPagingEnabled = true
        scrollView.scrollsToTop = false
        scrollView.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
        scrollView.bounces = true
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

        let panBlockGestureRecognizer = PanBlockGestureRecognizer(in: self.view)
        scrollView.addGestureRecognizer(panBlockGestureRecognizer)
        scrollView.panGestureRecognizer.require(toFail: panBlockGestureRecognizer)

        return scrollView
    }()

    private var beforeViewController: UIViewController?
    private var afterViewController: UIViewController?

    open private(set) var selectedViewController: UIViewController?
    open private(set) var scrolling = false
    open private(set) var navigationDirection: EMPageViewControllerNavigationDirection?

    private var adjustingContentOffset = false
    private var loadNewAdjoiningViewControllersOnFinish = false
    private var didFinishScrollingCompletionHandler: ((_ transitionSuccessful: Bool) -> Void)?
    private var transitionAnimated = false

    open func selectViewController(_ viewController: UIViewController, direction: EMPageViewControllerNavigationDirection, animated: Bool, completion: ((_ transitionSuccessful: Bool) -> Void)?) {
        if viewController == self.selectedViewController {
            return
        }
        if (direction == .forward) {
            self.afterViewController = viewController
            self.layoutViews()
            self.loadNewAdjoiningViewControllersOnFinish = true
            self.scrollForward(animated: animated, completion: completion)
        } else if (direction == .reverse) {
            self.beforeViewController = viewController
            self.layoutViews()
            self.loadNewAdjoiningViewControllersOnFinish = true
            self.scrollReverse(animated: animated, completion: completion)
        }
    }

    @objc(scrollForwardAnimated:completion:)
    open func scrollForward(animated: Bool, completion: ((_ transitionSuccessfull: Bool) -> Void)?) {
        if self.afterViewController != nil {
            if self.scrolling {
                self.scrollView.setContentOffset(CGPoint(x: self.view.bounds.width * 2, y: 0), animated: false)
            }
        }

        self.didFinishScrollingCompletionHandler = completion
        self.transitionAnimated = animated
        self.scrollView.setContentOffset(CGPoint(x: 0, y: self.view.bounds.height * 2), animated: animated)
    }

    @objc(scrollReverseAnimated:completion:)
    open func scrollReverse(animated: Bool, completion: ((_ transitionSuccessful: Bool) -> Void)?) {
        if self.beforeViewController != nil {
            if self.scrolling {
                self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            }

            self.didFinishScrollingCompletionHandler = completion
            self.transitionAnimated = animated
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: animated)
        }
    }

    open override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        self.scrollView.delegate = self
        self.view.addSubview(self.scrollView)
    }

    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        adjustingContentOffset = true

        self.scrollView.frame = self.view.bounds
        self.scrollView.contentSize = CGSize(width: self.view.bounds.width * 3, height: self.view.bounds.height)

        self.layoutViews()
    }

    private func loadViewControllers(_ selectedViewController: UIViewController) {
        if selectedViewController == self.afterViewController {
            self.beforeViewController = self.selectedViewController
            self.selectedViewController = self.afterViewController

            self.selectedViewController!.endAppearanceTransition()
            self.removeChildIfNeed(self.beforeViewController)
            self.beforeViewController?.endAppearanceTransition()
            self.delegate?.em_pageViewController?(self,
                                                 didFinishScrollingFrom: self.beforeViewController,
                                                 destinationViewController: self.selectedViewController!,
                                                 direction: .forward,
                                                 transitionSuccessful: true)

            self.didFinishScrollingCompletionHandler?(true)
            self.didFinishScrollingCompletionHandler = nil

            if self.loadNewAdjoiningViewControllersOnFinish {
                self.loadBeforeViewController(for: selectedViewController)
                self.loadNewAdjoiningViewControllersOnFinish = false
            }

            self.loadAfterViewController(for: selectedViewController)
        } else if selectedViewController == self.beforeViewController {
            self.afterViewController = self.selectedViewController
            self.selectedViewController = self.beforeViewController

            self.selectedViewController!.endAppearanceTransition()
            self.removeChildIfNeed(self.afterViewController)
            self.afterViewController?.endAppearanceTransition()
            self.delegate?.em_pageViewController?(self,
                                                 didFinishScrollingFrom: self.afterViewController!,
                                                 destinationViewController: self.selectedViewController!,
                                                 direction: .reverse,
                                                 transitionSuccessful: true)

            self.didFinishScrollingCompletionHandler?(true)
            self.didFinishScrollingCompletionHandler = nil

            if self.loadNewAdjoiningViewControllersOnFinish {
                self.loadAfterViewController(for: selectedViewController)
                self.loadNewAdjoiningViewControllersOnFinish = false
            }

            self.loadBeforeViewController(for: selectedViewController)
        } else if selectedViewController == self.selectedViewController {
            self.selectedViewController!.beginAppearanceTransition(true, animated: self.transitionAnimated)

            if self.navigationDirection == .forward {
                self.afterViewController!.beginAppearanceTransition(false, animated: self.transitionAnimated)
            }

            self.selectedViewController!.endAppearanceTransition()

            self.removeChildIfNeed(self.beforeViewController)
            self.removeChildIfNeed(self.afterViewController)

            if self.navigationDirection == .forward {
                self.afterViewController!.endAppearanceTransition()
                self.delegate?.em_pageViewController?(self,
                                                      didFinishScrollingFrom: self.selectedViewController!,
                                                      destinationViewController: self.afterViewController!,
                                                      direction: .forward,
                                                      transitionSuccessful: false)
            } else if self.navigationDirection == .reverse {
                self.beforeViewController!.endAppearanceTransition()
                self.delegate?.em_pageViewController?(self,
                                                     didFinishScrollingFrom: self.selectedViewController!,
                                                     destinationViewController: self.beforeViewController!,
                                                     direction: .reverse,
                                                     transitionSuccessful: false)
            } else {
                self.delegate?.em_pageViewController?(self,
                                                     didFinishScrollingFrom: self.selectedViewController!,
                                                     destinationViewController: self.selectedViewController!,
                                                     direction: .forward,
                                                     transitionSuccessful: true)
            }

            self.didFinishScrollingCompletionHandler?(false)
            self.didFinishScrollingCompletionHandler = nil

            if self.loadNewAdjoiningViewControllersOnFinish {
                if self.navigationDirection == .forward {
                    self.loadAfterViewController(for: selectedViewController)
                } else if self.navigationDirection == .reverse {
                    self.loadBeforeViewController(for: selectedViewController)
                }
            }
        }

        self.navigationDirection = nil
        self.scrolling = false
    }

    private func loadBeforeViewController(for selectedViewController: UIViewController) {
        if let beforeViewController = self.dataSource?.em_pageViewController(self, viewControllerBeforeViewController: selectedViewController) {
            self.beforeViewController = beforeViewController
        } else {
            self.beforeViewController = nil
        }
    }

    private func loadAfterViewController(for selectedViewController: UIViewController) {
        if let afterViewController = self.dataSource?.em_pageViewController(self, viewControllerAfterViewController: selectedViewController) {
            self.afterViewController = afterViewController
        } else {
            self.afterViewController = nil
        }
    }

    private func addChildIfNeed(_ viewController: UIViewController) {
        self.scrollView.addSubview(viewController.view)
        self.addChild(viewController)
        viewController.didMove(toParent: self)
    }

    private func removeChildIfNeed(_ viewController: UIViewController?) {
        viewController?.view.removeFromSuperview()
        viewController?.didMove(toParent: nil)
        viewController?.removeFromParent()
    }

    private func layoutViews() {
        let viewWidth = self.view.bounds.width
        let viewHeight = self.view.bounds.height

        self.adjustingContentOffset = true
        self.scrollView.contentOffset = CGPoint(x: viewWidth, y: viewHeight)
        self.adjustingContentOffset = false

        self.beforeViewController?.view.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        self.selectedViewController?.view.frame = CGRect(x: viewWidth, y: 0, width: viewWidth, height: viewHeight)
        self.afterViewController?.view.frame = CGRect(x: viewWidth * 2, y: 0, width: viewWidth, height: viewHeight)
    }

    private func willScroll(from startingViewController: UIViewController?, to destinationViewController: UIViewController) {
        if startingViewController != nil {
            self.delegate?.em_pageViewController?(self,
                                                 isScrollingFrom: startingViewController!,
                                                 destinationViewController: destinationViewController,
                                                 direction: self.navigationDirection ?? .forward)

        }

        destinationViewController.beginAppearanceTransition(true, animated: self.transitionAnimated)
        startingViewController?.beginAppearanceTransition(false, animated: self.transitionAnimated)
        self.addChildIfNeed(destinationViewController)
    }

    private func didFinishScrolling(to viewController: UIViewController) {
        self.loadViewControllers(viewController)
        self.layoutViews()
    }

    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !adjustingContentOffset {
            let distance = self.view.bounds.width
            let progress = (scrollView.contentOffset.x - distance) / distance

            if progress > 0 {
                if self.afterViewController != nil {
                    if !scrolling {
                        self.willScroll(from: self.selectedViewController, to: self.afterViewController!)
                        self.scrolling = true
                    }

                    if self.navigationDirection == .reverse {
                        self.didFinishScrolling(to: self.selectedViewController!)
                        self.willScroll(from: self.selectedViewController, to: self.afterViewController!)
                    }

                    self.navigationDirection = .forward

                    if self.selectedViewController != nil {
                        self.delegate?.em_pageViewController?(self,
                                                              isScrollingFrom: self.selectedViewController!,
                                                              destinationViewController: self.afterViewController!,
                                                              direction: self.navigationDirection ?? .forward,
                                                              progress: progress)
                    }
                } else {
                    if self.selectedViewController != nil {
                        self.delegate?.em_pageViewController?(self,
                                                              isScrollingFrom: self.selectedViewController!,
                                                              destinationViewController: nil,
                                                              direction: self.navigationDirection ?? .forward,
                                                              progress: progress)
                    }
                }
            } else if progress < 0 {
                if self.beforeViewController != nil {
                    if !scrolling {
                        self.willScroll(from: self.selectedViewController, to: self.beforeViewController!)
                        self.scrolling = true
                    }

                    if self.navigationDirection == .forward {
                        self.didFinishScrolling(to: self.selectedViewController!)
                        self.willScroll(from: self.selectedViewController, to: self.beforeViewController!)
                    }

                    self.navigationDirection = .reverse

                    if self.selectedViewController != nil {
                        self.delegate?.em_pageViewController?(self,
                                                             isScrollingFrom: self.selectedViewController!,
                                                             destinationViewController: self.beforeViewController!,
                                                             direction: self.navigationDirection ?? .reverse,
                                                             progress: progress)
                    }
                } else {
                    if self.selectedViewController != nil {
                        self.delegate?.em_pageViewController?(self,
                                                              isScrollingFrom: self.selectedViewController!,
                                                              destinationViewController: nil,
                                                              direction: self.navigationDirection ?? .reverse,
                                                              progress: progress)
                    }
                }
            } else {
                if self.navigationDirection == .forward {
                    self.delegate?.em_pageViewController?(self,
                                                          isScrollingFrom: self.selectedViewController!,
                                                          destinationViewController: self.afterViewController!,
                                                          direction: .reverse,
                                                          progress: progress)
                } else if self.navigationDirection == .reverse {
                    self.delegate?.em_pageViewController?(self,
                                                          isScrollingFrom: self.selectedViewController!,
                                                          destinationViewController: self.beforeViewController!,
                                                          direction: .reverse,
                                                          progress: progress)
                }
            }

            if progress >= 1 && self.afterViewController != nil {
                self.didFinishScrolling(to: self.afterViewController!)
            } else if progress <= -1 && self.beforeViewController != nil {
                self.didFinishScrolling(to: self.beforeViewController!)
            } else if progress == 0 && self.selectedViewController != nil {
                self.didFinishScrolling(to: self.selectedViewController!)
            }
        }
    }

    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.transitionAnimated = true
    }

    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (self.beforeViewController != nil && self.afterViewController != nil) ||
            (self.afterViewController != nil && self.beforeViewController == nil && scrollView.contentOffset.x > abs(scrollView.contentInset.left)) ||
            (self.beforeViewController != nil && self.afterViewController == nil && scrollView.contentOffset.x < abs(scrollView.contentInset.right)) {
            scrollView.setContentOffset(CGPoint(x: self.view.bounds.width, y: 0), animated: true)
        }
    }
}
