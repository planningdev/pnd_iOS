//
//  TabMenuView.swift
//  PageMenu
//
//  Created by Azuma on 2018/11/08.
//  Copyright © 2018 P&D. All rights reserved.
//

import UIKit

class TabMenuView: UIView {

    fileprivate var options: PageMenuOptions
    fileprivate var beforeIndex: Int = 0
    fileprivate var currentIndex: Int = 0
    fileprivate var pageTabItemsCount: Int = 0
    fileprivate var shouldScrollToItem: Bool = false
    fileprivate var pageTabItemsWidth: CGFloat = 0.0
    fileprivate var collectionViewContentOffsetX: CGFloat?
    fileprivate var currentBarViewWidth: CGFloat = 0.0
    fileprivate var cellForSize: TabMenuItemCell!
    fileprivate var distance: CGFloat = 0
    fileprivate var cursorView: TabMenuItemCursor!
    fileprivate var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .clear
        return contentView
    }()
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = self.options.tabMenuContentInset
        return collectionView
    }()

    var pageItemPressedBlock: ((_ index: Int, _ direction: EMPageViewControllerNavigationDirection) -> Void)?
    var layouted: Bool = false
    var pageTabItems: [String] = [] {
        didSet {
            self.pageTabItemsCount = self.pageTabItems.count
            self.beforeIndex = self.pageTabItems.count
            self.collectionView.reloadData()
            self.cursorView.isHidden = self.pageTabItems.isEmpty
        }
    }
    var isInfinite: Bool {
        return self.options.isInfinite
    }

    init(options: PageMenuOptions) {
        self.options = options
        super.init(frame: .zero)

        self.backgroundColor = options.tabMenuBackgroundColor

        // content view
        addSubview(self.contentView)
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.contentView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.contentView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        self.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        // collection view
        self.contentView.addSubview(self.collectionView)
        self.collectionView.register(TabMenuItemCell.self, forCellWithReuseIdentifier: TabMenuItemCell.cellIdentifier)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.collectionView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
        self.collectionView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
        self.collectionView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        self.cellForSize = TabMenuItemCell()
        self.collectionView.scrollsToTop = false
        self.collectionView.reloadData()

        switch self.options.menuCursor {
        case let .underline(barColor, _):
            let underlineView = UnderlineCursorView(frame: .zero)
            if self.isInfinite {
                underlineView.setup(parent: self.contentView, isInfinite: true, options: self.options)
            } else {
                underlineView.setup(parent: self.collectionView, isInfinite: false, options: self.options)
            }
            underlineView.backgroundColor = barColor
            self.cursorView = underlineView
        case let .roundRect(rectColor, cornerRadius, _, borderWidth, borderColor):
            let rectView = RoundRectCursorView(frame: .zero)
            if self.isInfinite {
                rectView.setup(parent: self.contentView, isInfinite: true, options: self.options)
            } else {
                rectView.setup(parent: self.contentView, isInfinite: false, options: self.options)
            }
            rectView.backgroundColor = rectColor
            rectView.layer.cornerRadius = cornerRadius
            if let borderWidth = borderWidth, let borderColor = borderColor {
                rectView.layer.borderWidth = borderWidth
                rectView.layer.borderColor = borderColor.cgColor
            }
            self.cursorView = rectView
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TabMenuView {

    func scrollCurrentBarView(_ index: Int, contentOffsetX: CGFloat, progress: CGFloat) {
        var nextIndex = isInfinite ? index + self.pageTabItemsCount : index

        if self.isInfinite && index == 0 && (self.beforeIndex - self.pageTabItemsCount) == self.pageTabItemsCount - 1 {
            nextIndex = pageTabItemsCount * 2
        } else if self.isInfinite && (index == self.pageTabItemsCount - 1) && (self.beforeIndex - self.pageTabItemsCount) == 0 {
            nextIndex = self.pageTabItemsCount - 1
        }

        let currentIndexPath = IndexPath(item: self.currentIndex, section: 0)
        let nextIndexPath = IndexPath(item: nextIndex, section: 0)

        self.cursorView.isHidden = false

        if let currentCell = collectionView.cellForItem(at: currentIndexPath) as? TabMenuItemCell, let nextCell = collectionView.cellForItem(at: nextIndexPath) as? TabMenuItemCell {
            self.collectionView.setContentOffset(self.collectionView.contentOffset, animated: false)
//            self.hidden
            if self.collectionViewContentOffsetX == nil {
                self.collectionViewContentOffsetX = self.collectionView.contentOffset.x
            }

            if currentBarViewWidth == 0.0 {
                currentBarViewWidth = currentCell.frame.width
            }

            if distance == 0 {
                var distance = self.distance(from: currentCell, to: nextCell)

                if self.collectionView.near(edge: .left, clearance: -distance) && distance < 0 {
                    distance = -(self.collectionView.contentOffset.x + self.collectionView.contentInset.left)
                } else if self.collectionView.near(edge: .right, clearance: distance) && distance > 0 {
                    distance = self.collectionView.contentSize.width - (self.collectionView.contentOffset.x + self.collectionView.bounds.width - self.collectionView.contentInset.right)
                }

                self.distance = distance
            }

            if progress > 0 {
                nextCell.highlightTitle(progress: progress)
                currentCell.unHighlightTitle(progress: progress)
            } else {
                nextCell.highlightTitle(progress: -1 * progress)
                currentCell.unHighlightTitle(progress: -1 * progress)
            }

            let width = abs(progress) * (nextCell.frame.width - currentCell.frame.width)
            let scroll = abs(progress) * self.distance

            if self.isInfinite {
                self.collectionView.contentOffset.x = (collectionViewContentOffsetX ?? 0) + scroll
            } else {
                let overflow = self.collectionView.frame.width < self.collectionView.contentSize.width

                if progress >= 0 && progress < 1 {
                    self.cursorView.updatePosition(x: currentCell.frame.minX + progress * currentCell.frame.width)

                    if overflow {
                        self.collectionView.contentOffset.x = (collectionViewContentOffsetX ?? 0) + scroll
                    }
                } else if progress > -1 && progress < 0 {
                    self.cursorView.updatePosition(x: currentCell.frame.minX + nextCell.frame.width * progress)

                    if overflow {
                        self.collectionView.contentOffset.x = (collectionViewContentOffsetX ?? 0) + scroll
                    }
                }
            }

            self.cursorView.updateWidth(width: self.currentBarViewWidth + width)
        } else {
//            self.hidd

            if let _ = self.collectionView.cellForItem(at: currentIndexPath) {
                self.collectionView.scrollToItem(at: currentIndexPath, at: .centeredHorizontally, animated: false)
            }
        }
    }

    fileprivate func distance(from: UICollectionViewCell, to: UICollectionViewCell) -> CGFloat {
        let distanceToCenter = collectionView.bounds.midX - from.frame.midX
        let distanceBetweenCells = to.frame.midX - from.frame.midX

        return distanceBetweenCells - distanceToCenter
    }

    func scrollToHorizontalCenter() {
        let indexPath = IndexPath(item: self.currentIndex, section: 0)

        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        self.collectionViewContentOffsetX = self.collectionView.contentOffset.x
    }

    func updateCurrentIndex(_ index: Int, shouldScroll: Bool, animated: Bool = false) {
        deselectVisibleCells()

        self.currentIndex = self.isInfinite ? index + self.pageTabItemsCount : index
        let indexPath = IndexPath(item: self.currentIndex, section: 0)
        moveCurrentBarView(indexPath, animated: animated, shouldScroll: shouldScroll)
    }

    fileprivate func updateCurrentIndexForTap(_ index: Int) {
        deselectVisibleCells()

        if self.isInfinite && (index < self.pageTabItemsCount) || (index >= self.pageTabItemsCount * 2) {
            self.currentIndex = (index < self.pageTabItemsCount) ? index + self.pageTabItemsCount : index - self.pageTabItemsCount
            self.shouldScrollToItem = true
        } else {
            self.currentIndex = index
        }

        let indexPath = IndexPath(item: index, section: 0)
        moveCurrentBarView(indexPath, animated: true, shouldScroll: true)
    }

    fileprivate func moveCurrentBarView(_ indexPath: IndexPath, animated: Bool, shouldScroll: Bool) {
        var targetIndexPath = indexPath

        self.distance = 0

        if shouldScroll {
            if self.isInfinite {
                targetIndexPath = IndexPath(item: indexPath.item % self.pageTabItemsCount + self.pageTabItemsCount, section: 0)
                self.collectionView.scrollToItem(at: targetIndexPath, at: .centeredHorizontally, animated: animated)
            } else {
                targetIndexPath = indexPath
                self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
            }
            self.layoutIfNeeded()
            self.collectionViewContentOffsetX = nil
            self.currentBarViewWidth = 0.0
        }

        if let cell = collectionView.cellForItem(at: targetIndexPath) as? TabMenuItemCell {
            if animated && shouldScroll {
                cell.highlightTitle()
                cell.isDecorationHidden = false
            }

            self.cursorView.updateWidth(width: cell.frame.width)

            if !isInfinite {
                self.cursorView.updatePosition(x: cell.frame.origin.x)
            }

            if !animated && shouldScroll {
                cell.highlightTitle()
                cell.isDecorationHidden = false
            }
        }

        self.beforeIndex = self.currentIndex
    }

    func updateCollectionViewUserInteractionEnabled(_ userInteractionEnabled: Bool) {
        collectionView.isUserInteractionEnabled = userInteractionEnabled
    }

    fileprivate func deselectVisibleCells() {
        self.collectionView.visibleCells
            .compactMap({ $0 as? TabMenuItemCell })
            .forEach {
                $0.unHighlightTitle()
                $0.isDecorationHidden = true
        }
    }

    fileprivate func hiddenVisibleDecorations() {
        self.collectionView.visibleCells
            .compactMap({ $0 as? TabMenuItemCell })
            .forEach({ $0.isDecorationHidden = true })
    }
}

extension TabMenuView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fixedIndex = self.isInfinite ? indexPath.item % self.pageTabItemsCount : indexPath.item
        var direction: EMPageViewControllerNavigationDirection = .forward

        if self.isInfinite == true {
            if (indexPath.item < self.pageTabItemsCount) || (indexPath.item < self.currentIndex) {
                direction = .reverse
            }
        } else {
            if indexPath.item < self.currentIndex {
                direction = .reverse
            }
        }

        self.updateCollectionViewUserInteractionEnabled(false)
        self.pageItemPressedBlock?(fixedIndex, direction)
        self.updateCurrentIndexForTap(indexPath.item)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging && self.isInfinite {
            self.cursorView.isHidden = true
            let indexPath = IndexPath(item: currentIndex, section: 0)
            if let cell = collectionView.cellForItem(at: indexPath) as? TabMenuItemCell {
                cell.isDecorationHidden = false
            }
        }

        guard self.isInfinite else {
            return
        }

        if self.pageTabItemsWidth == 0.0 {
            self.pageTabItemsWidth = floor(scrollView.contentSize.width / 3.0)
        }

        if (scrollView.contentOffset.x <= 0.0) || (scrollView.contentOffset.x > self.pageTabItemsWidth * 2.0) {
            scrollView.contentOffset.x = self.pageTabItemsWidth
        }
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.updateCollectionViewUserInteractionEnabled(true)

        guard self.isInfinite else {
            return
        }

        let indexPath = IndexPath(item: currentIndex, section: 0)
        if self.shouldScrollToItem {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            self.shouldScrollToItem = false
        }
    }
}

extension TabMenuView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.isInfinite ? self.pageTabItemsCount * 3 : self.pageTabItemsCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabMenuItemCell.cellIdentifier, for: indexPath) as! TabMenuItemCell
        self.configureCell(cell, indexPath: indexPath)
        return cell
    }

    func configureCell(_ cell: TabMenuItemCell, indexPath: IndexPath) {
        let fixedIndex = self.isInfinite ? indexPath.item % self.pageTabItemsCount : indexPath.item
        cell.configure(title: self.pageTabItems[fixedIndex], options: self.options)
        if fixedIndex == (self.currentIndex % self.pageTabItemsCount) {
            cell.highlightTitle()
            cell.isDecorationHidden = false
        } else {
            cell.unHighlightTitle()
            cell.isDecorationHidden = true
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? TabMenuItemCell, self.layouted {
            let fixedIndex = self.isInfinite ? indexPath.item % self.pageTabItemsCount :indexPath.item
            if fixedIndex == (self.currentIndex % self.pageTabItemsCount) {
                cell.isDecorationHidden = false
                cell.highlightTitle()
            } else {
                cell.isDecorationHidden = true
                cell.unHighlightTitle()
            }
        }
    }
}

extension TabMenuView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        self.configureCell(self.cellForSize, indexPath: indexPath)
        let size = cellForSize.sizeThatFits(CGSize(width: collectionView.bounds.width, height: self.options.menuItemSize.height))
        return size
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
