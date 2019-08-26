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
    public var cardHeight: CGFloat = 130
    
    /// Card height when collapsed
    public var collapsedHeight: CGFloat = 50
    
    /// Visible card area (height) when collapsed
    public var cardPeekHeight: CGFloat = 30
    
    public var horizontalSpacing: CGFloat = 10
    public var verticalSpacing: CGFloat = 30
    public var sectionSpacing: CGFloat = 200
    
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
}

open class CardStackCollectionViewLayout: UICollectionViewLayout {
    
    @IBOutlet public var delegate: CardStackLayoutDelegate?
    public var config = CardStackLayoutConfig()
    
    var contentBounds = CGRect.zero
    var contentHeight: CGFloat = 0.0
    var cachedAttributes = [Int: [UICollectionViewLayoutAttributes]]()
    
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
        
        let kFractionToMove: CGFloat = 0.0 // future dragging translation
        contentHeight = CGFloat(kFractionToMove)
        var prevSectionsContentHeight:CGFloat = 0.0
        cachedAttributes.removeAll()

        let sectionCount = collection.numberOfSections
        for section in 0..<sectionCount {
            let qty = collection.numberOfItems(inSection: section)
            for index in 0..<qty {
                
                let state = self.state(section)

                // add offset equal to previous section height
                let sectionOffset = prevSectionsContentHeight
                
                let layout = UICollectionViewLayoutAttributes(forCellWith: IndexPath(row: index, section: section))
                layout.frame = frameFor(index: index, cardState: state, translation: sectionOffset)
                
                // content height needs to be based on render At height not 'visual height' since we're stacking
                if (state == .expanded || state == .regular) && index != 0 {
                    contentHeight = layout.frame.origin.y + config.cardHeight + config.verticalSpacing
                } else if state == .collapsed  {
                    contentHeight = layout.frame.origin.y + config.cardPeekHeight
                }
                
                layout.zIndex = qty - index
                layout.isHidden = state == .collapsed ? index > config.normalStackDepthLimit : false
                
                if (cachedAttributes[section] == nil) {
                    cachedAttributes[section] = []
                }
                cachedAttributes[section]?.append(layout)
            }
            prevSectionsContentHeight += (contentHeight + config.sectionSpacing)
        }
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cachedAttributes.flatMap {
            $1.filter { rect.intersects($0.frame) }
        } /// todo: optimize this filter op
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.section]?[indexPath.row]
    }
    
    // MARK: - Insert/Delete Transitions
    /// UIKit will automatically animate between these (appear/disappear) attributes, and the regular attributes.
    
    /// APPEAR: Default animation is fine.
    
    /// DISAPPEAR: Animate offscreen to the right edge, with a bit of rotational transform
    override open func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = UICollectionViewLayoutAttributes(forCellWith: itemIndexPath)
        let frame = frameFor(index: itemIndexPath.row, cardState: state(itemIndexPath.section), translation: 0)
        attr.frame = CGRect(x: frame.maxX + fullWidth, y: frame.maxY - 40, width: frame.width, height: frame.height)
        attr.transform = CGAffineTransform(rotationAngle: 0.3)
        return config.showDeleteAnimation ? attr : nil
    }
    
    // MARK: - Frame Calculations
    private func frameFor(index: Int, cardState: CardStackLayoutState, translation: CGFloat) -> CGRect {
        
        // Card widths
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
        
        let origin = CGPoint(x: config.horizontalSpacing + (additionalHorizontalPadding / 2), y: translation)
        let width = fullWidth - (config.horizontalSpacing + config.horizontalSpacing + additionalHorizontalPadding)

        var frame = CGRect(origin: origin, size: CGSize(width: width, height: config.cardHeight))
        
        if index == 0 {
            return frame
        }
        
        // Apply index offsets, padding to the bottom of the cell if not 0th
        switch cardState {
        case .expanded, .regular:
            let heights = (config.cardHeight * CGFloat(index))
            let spaces = (config.verticalSpacing * CGFloat(index))
            frame.origin.y = spaces + heights + translation
        case .collapsed:
            let limitedIndex = min(config.normalStackDepthLimit, index)
            frame.origin.y = (config.cardPeekHeight * CGFloat(limitedIndex)) + translation
        }
        
        return frame
    }
}
