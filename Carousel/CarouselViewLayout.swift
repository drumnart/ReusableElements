//
//  CarouselViewLayout.swift
//
//  Created by Sergey Gorin on 26/03/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

class CarouselViewLayout: UICollectionViewLayout {
    
    var shouldPrepare = true
    
    var itemSize: CGSize = .zero
    
    var scrollDirection: UICollectionView.ScrollDirection = .horizontal {
        didSet {
            forcePrepare()
        }
    }
    
    var interitemSpacing: CGFloat = 0.0 {
        didSet {
            forcePrepare()
        }
    }
    
    var isInfinite: Bool = true {
        didSet {
            forcePrepare()
        }
    }
    
    var minVelocityForTargetOffset: CGFloat = 0.2
    
    private(set) var itemSpread: CGFloat = 0 // spacing occupied by item + interitem spacing
    
    private var shouldInvalidateContentOffset = true
    private var sectionInsets: UIEdgeInsets = .zero
    private var contentSize: CGSize = .zero
    private var numberOfSections: Int {
        return collectionView?.numberOfSections ?? 0
    }
    private var numberOfItems: Int {
        guard collectionView?.numberOfSections > 0 else { return 0 }
        return collectionView?.numberOfItems(inSection: 0) ?? 0
    }
    
    // MARK: - Overrides
    
    override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func prepare() {
        guard shouldPrepare, let collectionView = collectionView else { return }
        shouldPrepare = false
        
        if itemSize == .zero {
            itemSize = collectionView.frame.size
        }
        
        sectionInsets = {
            let inset = scrollDirection == .horizontal
                ? (collectionView.frame.width - itemSize.width).half
                : (collectionView.frame.height - itemSize.height).half
            
            return scrollDirection == .horizontal
                ? UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
                : UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
        }()
        
        itemSpread = scrollDirection == .horizontal
            ? itemSize.width + interitemSpacing
            : itemSize.height + interitemSpacing
        
        contentSize = {
            let count = numberOfItems * numberOfSections
            
            guard count > 0 else { return .zero }
            
            let spacing = CGFloat(count - 1) * interitemSpacing
            switch scrollDirection {
            case .horizontal:
                let width = CGFloat(count) * itemSize.width
                return CGSize(width: width + sectionInsets.leftRight + spacing,
                              height: collectionView.frame.height)
                
            case .vertical:
                let height = CGFloat(count) * itemSize.height
                return CGSize(width: collectionView.frame.width,
                              height: height + sectionInsets.topBottom + spacing)
                
            @unknown default: return .zero
            }
        }()
        
        adjustContentOffset()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes: [UICollectionViewLayoutAttributes] = []
        let rect = rect.intersection(CGRect(origin: .zero, size: contentSize))
        
        guard itemSpread > 0, !rect.isEmpty else { return [] }
        
        let startIndex: Int
        let minPosition: CGFloat
        let maxPosition: CGFloat
        
        switch scrollDirection {
        case .horizontal:
            startIndex = max(Int((rect.minX - sectionInsets.left) / itemSpread), 0)
            minPosition = sectionInsets.left + CGFloat(startIndex) * itemSpread
            maxPosition = min(rect.maxX, contentSize.width - sectionInsets.right - itemSize.width)
            
        case .vertical:
            startIndex = max(Int((rect.minY - sectionInsets.top) / itemSpread), 0)
            minPosition = sectionInsets.top + CGFloat(startIndex) * itemSpread
            maxPosition = min(rect.maxY, contentSize.height - sectionInsets.bottom - itemSize.height)
            
        @unknown default:
            startIndex = 0
            minPosition = 0
            maxPosition = 0
        }
        
        let endIndex = startIndex + Int(ceil((maxPosition - minPosition) / itemSpread))
        
        for i in startIndex ... endIndex {
            let indexPath = IndexPath(item: i % numberOfItems, section: i / numberOfItems)
            if let attributes = layoutAttributesForItem(at: indexPath) {
                layoutAttributes.append(attributes)
            }
        }
        
        return layoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return UICollectionViewLayoutAttributes(forCellWith: indexPath).with {
            $0.center = frame(for: indexPath).center
            $0.size = itemSize
        }
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard let collectionView = collectionView, !collectionView.isPagingEnabled else {
            return proposedContentOffset
        }
        
        var offsetAdjustment = proposedContentOffset
        let translation = collectionView.panGestureRecognizer.translation(in: collectionView)
        
        switch scrollDirection {
        case .horizontal:
            offsetAdjustment.x = round(proposedContentOffset.x / itemSpread) * itemSpread
            let threshold = min(itemSpread.half, collectionView.bounds.size.width * 0.4)
            let horizontalOffset = collectionView.contentOffset.x + translation.x
            
            if abs(translation.x) <= threshold {
                if abs(velocity.x) >= minVelocityForTargetOffset &&
                    abs(proposedContentOffset.x - horizontalOffset) <= itemSpread.half {
                    offsetAdjustment.x += itemSpread * velocity.x / abs(velocity.x)
                }
            }
            
        case .vertical:
            offsetAdjustment.y = round(proposedContentOffset.y / itemSpread) * itemSpread
            let threshold = min(itemSpread.half, collectionView.bounds.size.height * 0.4)
            let verticalOffset = collectionView.contentOffset.y + translation.y
            
            if abs(translation.y) <= threshold {
                if abs(velocity.y) >= minVelocityForTargetOffset &&
                    abs(proposedContentOffset.y - verticalOffset) <= itemSpread.half {
                    offsetAdjustment.y += itemSpread * velocity.y / abs(velocity.y)
                }
            }
            
        @unknown default: break
        }
        
        return offsetAdjustment
    }
}

// MARK - Helpers
extension CarouselViewLayout {
    
    func forcePrepare(resetContentOffset: Bool = true) {
        shouldPrepare = true
        shouldInvalidateContentOffset = resetContentOffset
        invalidateLayout()
    }
    
    func preferredContentOffset(for indexPath: IndexPath) -> CGPoint {
        guard let cv = collectionView else { return .zero }
        let origin = frame(for: indexPath).origin
        switch scrollDirection {
        case .horizontal:
            return CGPoint(x: origin.x - 0.5 * (cv.frame.width - itemSize.width),
                           y: 0)
            
        case .vertical:
            return CGPoint(x: 0,
                           y: origin.y - 0.5 * (cv.frame.width - itemSize.width))
            
        @unknown default:
            return .zero
        }
    }
    
    private func adjustContentOffset() {
        defer { shouldInvalidateContentOffset = true }
        guard let cv = collectionView, shouldInvalidateContentOffset else { return }
        
        let page = Int(cv.contentOffset.x /? contentSize.width)
        let indexPath = IndexPath(item: page,
                                  section: isInfinite ? numberOfSections / 2 : 0)
        let contentOffset = preferredContentOffset(for: indexPath)
        
        cv.contentOffset = contentOffset
    }
    
    private func flatIndex(for indexPath: IndexPath) -> Int {
        return numberOfItems * indexPath.section + indexPath.item
    }
    
    private func frame(for indexPath: IndexPath) -> CGRect {
        guard let cv = collectionView else { return .zero }
        let index = flatIndex(for: indexPath)
        let origin: CGPoint = {
            switch scrollDirection {
            case .horizontal:
                return CGPoint(x: sectionInsets.left + CGFloat(index) * itemSpread,
                               y: (cv.frame.height - itemSize.height).half + cv.contentOffset.y)
                
            case .vertical:
                return CGPoint(x: (cv.frame.width - itemSize.width).half + cv.contentOffset.x,
                               y: sectionInsets.top + CGFloat(index) * itemSpread)
                
            @unknown default:
                return .zero
            }
        }()
        return CGRect(origin: origin, size: itemSize)
    }
}
