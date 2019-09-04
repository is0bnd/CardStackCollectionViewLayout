//
//  CardCollectionViewLayout.swift
//  CardStackCollectionViewLayout
//
//  Created by Chris Stamper on 8/19/19.
//  Copyright © 2019 Chris Stamper. All rights reserved.
//
//  CardStackCollectionViewLayout provides UICollectionViewLayout
//  using a stacked card metaphore, similar to Apple Wallet's Card view.
//  The 0th (uppermost) card is displayed on the top of the stack, and the
//  stack may be expanded (fanned-out) or displayed normally as a stack of
//  cards with a small portion of the bottom of each card visible. Cell/card
//  insert and delete transitions are provided (swipe from top of stack for
//  example).

import UIKit

public struct CardStackLayoutConfig {
    /// Fully-expanded height
    public var cardHeight: CGFloat = 100
    
    /// Card height when collapsed
    public var collapsedHeight: CGFloat = 50
    
    /// Visible card area (height) when collapsed
    public var cardPeekHeight: CGFloat = 30
    
    public var horizontalSpacing: CGFloat = 10
    public var verticalSpacing: CGFloat = 30
    public var sectionSpacing: CGFloat = 50
    
    /// Card width offset (multiplied by position) when collapsed
    public var depthWidthOffset: CGFloat = 30
    
    /// Number of cards shown in the collapsed state
    public var normalStackDepthLimit: Int = 3
    
    /// When removing cells, animates a 'flip' off the right edge
    public var showDeleteAnimation: Bool = true
}

@objc public enum CardStackLayoutState: Int {
    case collapsed
    case expanded
    case regular // not a card stac, just a list
}

@objc public protocol CardStackLayoutDelegate: class {
    func currentState(section: Int) -> CardStackLayoutState
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
}

open class CardStackCollectionViewLayout: UICollectionViewLayout {
    
    @IBOutlet public var delegate: CardStackLayoutDelegate?
    public var config = CardStackLayoutConfig()
    
    var contentBounds = CGRect.zero
    var contentHeight: CGFloat = 0.0
    
    /// cell attributes
    var cachedAttributes = [Int: [UICollectionViewLayoutAttributes]]()
    /// supplementary view attributes indexed by section
    var cachedHeaderAttributes = [Int: UICollectionViewLayoutAttributes]()
    var cachedFooterAttributes = [Int: UICollectionViewLayoutAttributes]()
    
    private var fullWidth: CGFloat { get { collectionView?.frame.size.width ?? UIScreen.main.bounds.width }}
    
    func state(_ section: Int) -> CardStackLayoutState {
        return delegate?.currentState(section: section) ?? .collapsed
    }
    
    var lastRenderedState: CardStackLayoutState?
    
    override open var collectionViewContentSize: CGSize { get {
        
        guard let collection = self.collectionView else {
            return CGSize(width: 30, height: 30)
        }
        
        let width = collection.bounds.size.width
        let height = contentHeight
        return CGSize(width: width, height: height)
    }}
    
    // MARK: - Basic Layout
    /// layout computation is done and cached during prepare (called when layout invalidates)
    override open func prepare() {
        super.prepare()
        
        guard let collection = self.collectionView else {
            return
        }
        
        // SUPPLEMENTARY VIEWS
        /// inserts attributes for a supplementary view, given the frame of the first/last ('related item') cell in section
        /// returns the offset added in the primary axis (height)
        func insertSupplementaryAttribute(for indexPath: IndexPath, kind: String, relatedItemFrame: CGRect) -> CGFloat {
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: kind, with: indexPath)
            let isHeader = kind == UICollectionView.elementKindSectionHeader
            if let delegate = self.delegate, let collection = self.collectionView {
                if isHeader, let value = delegate.collectionView?(collection, layout: self, referenceSizeForHeaderInSection: indexPath.section) {
                    let ypos = (relatedItemFrame.origin.y - value.height)
                    attributes.frame = CGRect(x: (fullWidth - value.width) / 2,
                                              y: ypos,
                                              width: value.width,
                                              height: value.height)
                    attributes.frame.size = CGSize(width: value.width, height: value.height)
                    cachedHeaderAttributes[indexPath.section] = attributes
                } else if !isHeader, let value = delegate.collectionView?(collection, layout: self, referenceSizeForFooterInSection: indexPath.section) {
                    let ypos = (relatedItemFrame.origin.y + relatedItemFrame.size.height)
                    attributes.frame = CGRect(x: (fullWidth - value.width) / 2,
                                              y: ypos,
                                              width: value.width,
                                              height: value.height)
                    attributes.frame.size = CGSize(width: value.width, height: value.height)
                    cachedFooterAttributes[indexPath.section] = attributes
                }
                return attributes.frame.size.height
            }
            return 0
        }

        // CELLS
        let kFractionToMove: CGFloat = 0.0 // future dragging translation
        contentHeight = CGFloat(kFractionToMove)
        cachedAttributes.removeAll()

        let sectionCount = collection.numberOfSections
        for section in 0..<sectionCount {
            let qty = collection.numberOfItems(inSection: section)
            
            for row in 0..<qty {
                
                let state = self.state(section)
                
                let layout = UICollectionViewLayoutAttributes(forCellWith: IndexPath(row: row, section: section))
                layout.frame = frameFor(index: IndexPath(row: row, section: section),
                                        cardState: state,
                                        translation: kFractionToMove)
                
                // content height might be based on a render height not 'visual height' since we're stacking
                let isLast = row == (qty - 1)
                if isLast {
                    contentHeight = layout.frame.origin.y + layout.frame.size.height
                } else if (state == .expanded || state == .regular) {
                    contentHeight = layout.frame.origin.y + layout.frame.size.height + config.verticalSpacing
                } else if state == .collapsed  {
                    contentHeight = layout.frame.origin.y + config.cardPeekHeight
                }
                
                layout.zIndex = qty - row
                layout.isHidden = state == .collapsed ? row > config.normalStackDepthLimit : false
                
                if (cachedAttributes[section] == nil) {
                    cachedAttributes[section] = []
                }
                cachedAttributes[section]?.append(layout)
            }
            contentHeight += config.sectionSpacing
            
            // HEADER
            let headerItemIndex = IndexPath(row: 0, section: section)
            if let headerRelatedCellAttr = cachedAttributes[headerItemIndex.section]?[headerItemIndex.row] {
                let offset = insertSupplementaryAttribute(for: headerItemIndex,
                    kind: UICollectionView.elementKindSectionHeader,
                    relatedItemFrame: headerRelatedCellAttr.frame)
                contentHeight += offset
            }
            
            // FOOTER
            let footerItemIndex = IndexPath(row: qty - 1, section: section)
            if let footerRelatedCellAttr = cachedAttributes[footerItemIndex.section]?[footerItemIndex.row] {
                let offset = insertSupplementaryAttribute(for: footerItemIndex,
                    kind: UICollectionView.elementKindSectionFooter,
                    relatedItemFrame: footerRelatedCellAttr.frame)
                contentHeight += offset
            }
        }
    }
    
    /// returns cached attributes for ANY item type
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let cells = cachedAttributes.flatMap {
            $1.filter { rect.intersects($0.frame) }
        }
        let headers = cachedHeaderAttributes.compactMap { $0.value }.filter {
            rect.intersects($0.frame)
        }
        let footers = cachedFooterAttributes.compactMap { $0.value }.filter {
            rect.intersects($0.frame)
        }
        return [cells, headers, footers].flatMap{ $0 }
        /// todo: optimize this filter op
    }
    
    /// cached cell attributes
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.section]?[indexPath.row]
    }
    
    /// cached header/footer attributes
    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == UICollectionView.elementKindSectionHeader {
            return cachedHeaderAttributes[indexPath.section]
        } else {
            return cachedFooterAttributes[indexPath.section]
        }
    }
    
    // MARK: - Insert/Delete Transitions
    /// UIKit will automatically animate between these (appear/disappear) attributes, and the regular attributes.
    
    /// APPEAR: Default animation is fine.
    
    /// DISAPPEAR: Animate offscreen to the right edge, with a bit of rotational transform
    override open func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = UICollectionViewLayoutAttributes(forCellWith: itemIndexPath)
        let frame = attr.frame
        attr.frame = CGRect(x: frame.maxX + fullWidth, y: frame.maxY - 40, width: frame.width, height: frame.height)
        attr.transform = CGAffineTransform(rotationAngle: 0.3)
        return config.showDeleteAnimation ? attr : nil
    }
    
    // MARK: - Frame Calculations
    /// currently this can only be run in-order as it is iterative
    /// todo: instead use an offset parameter, and write code to generate it w/o full layout
    private func frameFor(index indexPath: IndexPath, cardState: CardStackLayoutState, translation: CGFloat) -> CGRect {
        
        let index = indexPath.row
        
        // WIDTHS (if collapsed, we will progressively inset rows horizontally) like:
        // [________________]
        //   [____________]
        //      [______]
        
        let insetBy: CGFloat = {
            let coefficent = index //, config.normalStackDepthLimit)
            var additionalHorizontalPadding: CGFloat = 0
            switch cardState {
            case .collapsed:
                // NORMAL/COLLAPSED
                // 1...3 should gradually decrease width, aftward remain fixed. 0th remains full width.
                additionalHorizontalPadding = coefficent == 0 ? 0.0 : (CGFloat(coefficent) * config.depthWidthOffset)
            case .expanded:
                // EXPANDED
                // card width should be consistent, but smaller than the 0th
                additionalHorizontalPadding = coefficent == 0 ? 0.0 : config.depthWidthOffset
            case .regular:
                // NOT A STACK
                // no need to show indentation at all
                additionalHorizontalPadding = 0
            }
            return additionalHorizontalPadding
        }()
        let width = fullWidth - (config.horizontalSpacing + config.horizontalSpacing + insetBy)
        
        // HEIGHTS
        var height = config.cardHeight
        if let c = collectionView,
            let size = delegate?.collectionView?(c, layout: self, sizeForItemAt: indexPath) {
                height = size.height
        }
        
        // POSITIONS
        let origin = CGPoint(x: config.horizontalSpacing + (insetBy / 2),
                             y: contentHeight)
        
        return CGRect(origin: origin, size: CGSize(width: width, height: height))
    }
}
