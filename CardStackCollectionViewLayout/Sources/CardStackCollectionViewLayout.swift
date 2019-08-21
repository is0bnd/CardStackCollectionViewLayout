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
    public let cardHeight: CGFloat = 100
    
    /// Card height when collapsed
    public let collapsedHeight: CGFloat = 50
    
    /// Visible card area (height) when collapsed
    public let cardPeekHeight: CGFloat = 30
    
    public let horizontalSpacing: CGFloat = 10
    public let verticalSpacing: CGFloat = 30

    /// Card width offset (multiplied by position) when collapsed
    public let depthWidthOffset: CGFloat = 30
}

public enum CardStackLayoutState {
    case normal
    case expanded
}

public protocol CardStackLayoutDelegate {
    var currentState: CardStackLayoutState { get }
}

open class CardStackCollectionViewLayout: UICollectionViewLayout {
    
    public var delegate: CardStackLayoutDelegate?
    public var config = CardStackLayoutConfig()
    
    var contentBounds = CGRect.zero
    var contentHeight: CGFloat = 0.0
    var cachedAttributes = [UICollectionViewLayoutAttributes]()
    
    private var fullWidth: CGFloat { get { collectionView?.frame.size.width ?? UIScreen.main.bounds.width }}
    
    var state: CardStackLayoutState { get {
        return delegate?.currentState ?? .normal
    }}
    
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
        
        let kFractionToMove: Float = 0.0 // dragging translation
        
        contentHeight = state == .expanded ? 0.0 : config.collapsedHeight + CGFloat(kFractionToMove)

        cachedAttributes.removeAll()
        contentBounds = CGRect(origin: .zero, size: collection.bounds.size)

        let qty = collection.numberOfItems(inSection: 0)
        for index in 0..<qty {
              let layout = UICollectionViewLayoutAttributes(forCellWith: IndexPath(row: index, section: 0))
              layout.frame = frameFor(index: index, cardState: state, translation: kFractionToMove)
              if state == .expanded {
                  contentHeight += CGFloat(config.verticalSpacing) + layout.frame.size.height
              }
              layout.zIndex = qty - index
              layout.isHidden = false

            cachedAttributes.append(layout)
        }
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cachedAttributes.filter { rect.intersects($0.frame) } /// todo: optimize this filter op
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.row]
    }
    
    // MARK: - Insert/Delete Transitions
    /// UIKit will automatically animate between these (appear/disappear) attributes, and the regular attributes.

    /// APPEAR: Default animation is fine.
    
    /// DISAPPEAR: Animate offscreen to the right edge, with a bit of rotational transform
    override open func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = UICollectionViewLayoutAttributes()
        let frame = frameFor(index: itemIndexPath.row, cardState: state, translation: 0)
        attr.frame = CGRect(x: frame.maxX + fullWidth, y: frame.maxY - 40, width: frame.width, height: frame.height)
        attr.transform = CGAffineTransform(rotationAngle: 0.3)
        return attr
    }
    
    // MARK: - Frame Calculations
    private func frameFor(index: Int, cardState: CardStackLayoutState, translation: Float) -> CGRect {
        
        // Card widths
        let widthDecreaseCutoff = 3
        let coefficent = min(index, widthDecreaseCutoff)
        var additionalHorizontalPadding: CGFloat = 0
        if cardState == .normal {
            // NORMAL/COLLAPSED
            // 1...3 should gradually decrease width, aftward remain fixed. 0th remains full width.
            additionalHorizontalPadding = coefficent == 0 ? 0.0 : CGFloat(coefficent) * config.depthWidthOffset
        } else {
            // EXPANDED
            // card width should be consistent, but smaller than the 0th
            additionalHorizontalPadding = coefficent == 0 ? 0.0 : config.depthWidthOffset
        }
        
        let origin = CGPoint(x: config.horizontalSpacing + (additionalHorizontalPadding / 2), y:0)
        let width = fullWidth - (config.horizontalSpacing + config.horizontalSpacing) - additionalHorizontalPadding
        var frame = CGRect(origin: origin, size: CGSize(width: width, height: config.cardHeight))
       
        // Card states adjustment
        switch cardState {
        case .expanded:
            let val = (config.cardHeight * CGFloat(index))
            frame.origin.y = (config.verticalSpacing * CGFloat(index)) + val
            
        case .normal:
            frame.origin.y = config.verticalSpacing + (config.cardPeekHeight * CGFloat(index))
        }
        
        return frame
    }
}
