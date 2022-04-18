//
//  RelaxLayout.swift
//
//  Created by Sergey Gorin on 08/12/2018.
//  Copyright © 2018 Sergey Gorin. All rights reserved.
//

import UIKit

extension RelaxLayout {
    // Struct with properties for layout
    struct Settings {
        
        // Geometry:
        
        /// Cell size. Default is 100 x 100
        var itemSize: CGSize = CGSize(width: 100.0, height: 100.0)
        
        /// Collection view's Main Header size. Default is zero.
        var headerSize: CGSize = .zero
        
        /// Section Header size. Default is zero.
        var sectionHeaderSize: CGSize = .zero
        
        /// Section Footer size. Default is zero.
        var sectionFooterSize: CGSize = .zero
        
        /// Main Header offset. Default is zero.
        var headerOffset: CGPoint = .zero
        
        /// Section Header offset. Default is zero.
        var sectionHeaderOffset: CGPoint = .zero
        
        /// Section Footer offset. Default is zero.
        var sectionFooterOffset: CGPoint = .zero
        
        /// Section Insets for division with cells. Default is zero.
        var sectionInsets: UIEdgeInsets = .zero
        
        /// Color of canvas below Section Header. Default is nil.
        var sectionHeaderCanvasColor: UIColor?
        
        /// Color of canvas below Cells. Default is nil.
        var sectionBodyCanvasColor: UIColor?
        
        /// Color of canvas below Section Footer. Default is nil.
        var sectionFooterCanvasColor: UIColor?
        
        /// Whether canvases should respect section insets
        var bodyCanvasRespectsSectionInsets: Bool = false
        
        /// Horizontal spacing between cells. Default is 0.
        var interitemSpacing: CGFloat = 0.0
        
        /// Vertical spacing between cells. Default is 0.
        var lineSpacing: CGFloat = 0.0
        
        /// Max offset for Parallax transformation in cells. Default is 50.0
        var maxParallaxGab: CGFloat = 50.0
        
        // Features:
        
        /// Direction for scrolling in layout. Default is vertical.
        var scrollDirection: UICollectionView.ScrollDirection = .vertical
        
        /// Maximum alpha for Header overlay. Default is 0.
        var headerOverlayMaxAlpha: CGFloat = 0.0
        
        /// Header's sliding rate to achieve parralax effect. Default is 0.5.
        var headerShiftRate: CGFloat = 0.5
        
        /// Indicates if Header is strechable. Default is false.
        var isHeaderStretchy: Bool = false
        
        /// Indicates if Header should pin to bounds during scrolling. Default is false.
        var headerPinsToVisibleBounds: Bool = false
        
        /// Sets maximim Z index for Header. Default is true.
        var bringHeaderAlwaysToFront: Bool = false
        
        /// Indicates if parallax in cells is enabled. Default is false.
        var isParallaxInCellsEnabled: Bool = false
        
        /// Indicates if section headers should pin to bounds during scrolling. Default is false.
        var sectionHeadersPinToVisibleBounds: Bool = false
        
        /// Indicates if section footers should pin to bounds during scrolling. Default is false.
        var sectionFootersPinToVisibleBounds: Bool = false
        
        /// Offset of the pinned Section Header if sectionHeadersPinToVisibleBounds is true.
        /// Default value is nil, that means that section header would stick to the top left corner
        /// of a collectionView but preserving superview's top margin.
        var pinPointOffsetForSectionHeader: CGPoint?
        
        /// Offset of the pinned Section Footer if sectionFootersPinToVisibleBounds is true.
        /// Default value is nil, that means that section header would stick to the bottom
        /// left corner of a collectionView but preserving superview's bottom margin.
        var pinPointOffsetForSectionFooter: CGPoint?
        
        // Grid lines and Separators:
        
        /// Option Set used for composing separators relative to collection view
        public struct SeparatorArrangement: OptionSet {
            public let rawValue: UInt
            
            static let none = SeparatorArrangement(rawValue: 0 << 0)
            static let interitem = SeparatorArrangement(rawValue: 1 << 0)
            static let interline = SeparatorArrangement(rawValue: 1 << 1)
            static let edgeTop = SeparatorArrangement(rawValue: 1 << 2)
            static let edgeLeft = SeparatorArrangement(rawValue: 1 << 3)
            static let edgeBottom = SeparatorArrangement(rawValue: 1 << 4)
            static let edgeRight = SeparatorArrangement(rawValue: 1 << 5)
            
            /// All vertical lines
            static let verticals: SeparatorArrangement = [.edgeLeft, .interitem, .edgeRight]
            
            /// All horizontal lines
            static let horizontals: SeparatorArrangement = [.edgeTop, .interline, .edgeBottom]
            
            static let all: SeparatorArrangement = [.horizontals, .verticals]
            
            public init(rawValue: UInt) {
                self.rawValue = rawValue
            }
        }
        
        /// Different appearance modes of separators
        enum SeparatorStyle {
            /// Internal separators are disposed in the middle of adjacent cells spacing.
            case `default`
            
            /// Make cells bordered.
            case bordered
        }
        
        /// Specifies all required positions of separators. Default is none.
        /// Note that separators appearance also depends on parameters such as
        /// the interitem/line spacing, sections insets, the separator color.
        var separatorsArrangement: SeparatorArrangement = .none
        
        /// Style of separators arrangement.
        var separatorStyle: SeparatorStyle = .default
        
        /// Thickness of separators. Default is 1.0.
        var separatorWidth: CGFloat = 1.0
        
        /// Edge Side
        enum Edge {
            case top, left, bottom, right
        }
        
        /// Is Separator visible
        
        /// Colors of separators. Default is nil.
        var separatorColor: (_ collectionView: UICollectionView, _ edge: Edge, _ indexPath: IndexPath) -> UIColor? = { _,_,_ in
            return nil
        }
        
        /// This setting is intended to tune lengths of separators.
        /// Default is UIEdgeInsets(top: 0, left: -1, bottom: 0, right: -1)
        /// For vertical separators only top and bottom insets will be taken into consideration.
        /// For horizontal separators only left and right insets will be taken into consideration.
        /// - parameter edge: edge side of the cell
        /// - parameter indexPath: indexPath of the cell
        var separatorInsets: (_ collectionView: UICollectionView, _ edge: Edge, _ indexPath: IndexPath) -> UIEdgeInsets = { _,_,_ in
            return .apply(left: -1, right: -1)
        }
        
        /// This setting is intended to tune positions of separators.
        /// Default is .zero
        /// - parameter edge: edge side of the cell
        /// - parameter indexPath: indexPath of the cell
        var separatorOffset: (_ collectionView: UICollectionView, _ edge: Edge, _ indexPath: IndexPath) -> CGPoint = { _,_,_ in
            return .zero
        }
    }
}

protocol RelaxLayoutDelegate: NSObjectProtocol {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout: RelaxLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    
    func collectionView(_ collectionView: UICollectionView,
                        layout: RelaxLayout,
                        insetsForSection section: Int) -> UIEdgeInsets
    
    func collectionView(_ collectionView: UICollectionView,
                        layout: RelaxLayout,
                        colorOfBodyCanvasForSection section: Int) -> UIColor?

    func collectionView(_ collectionView: UICollectionView,
                        layout: RelaxLayout,
                        sizeForHeaderInSection section: Int) -> CGSize
    
    func collectionView(_ collectionView: UICollectionView,
                        layout: RelaxLayout,
                        sizeForFooterInSection section: Int) -> CGSize
    
    func collectionView(_ collectionView: UICollectionView,
                        layout: RelaxLayout,
                        colorOfHeaderCanvasForSection section: Int) -> UIColor?
    
    func collectionView(_ collectionView: UICollectionView,
                        layout: RelaxLayout,
                        colorOfFooterCanvasForSection section: Int) -> UIColor?
}

extension RelaxLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout: RelaxLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return layout.settings.itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout: RelaxLayout,
                        insetsForSection section: Int) -> UIEdgeInsets {
        return layout.settings.sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout: RelaxLayout,
                        colorOfBodyCanvasForSection section: Int) -> UIColor? {
        return layout.settings.sectionBodyCanvasColor
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout: RelaxLayout,
                        sizeForHeaderInSection section: Int) -> CGSize {
        return layout.settings.sectionHeaderSize
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout: RelaxLayout,
                        sizeForFooterInSection section: Int) -> CGSize {
        return layout.settings.sectionHeaderSize
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout: RelaxLayout,
                        colorOfHeaderCanvasForSection section: Int) -> UIColor? {
        return layout.settings.sectionHeaderCanvasColor
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout: RelaxLayout,
                        colorOfFooterCanvasForSection section: Int) -> UIColor? {
        return layout.settings.sectionFooterCanvasColor
    }
}

//extension RelaxLayoutDelegate where Self: UICollectionViewDelegate {}

/// Custom Collection View Layout with different convinient features.
class RelaxLayout: UICollectionViewLayout {
    
    enum Element {
        case header
        case sectionHeader
        case sectionFooter
        case sectionCanvas
        case cell
        case topStroke
        case leftStroke
        case bottomStroke
        case rightStroke
        
        var kind: String {
            switch self {
            case .sectionHeader: return UICollectionView.elementKindSectionHeader
            case .sectionFooter: return UICollectionView.elementKindSectionFooter
            default: return "Kind" + String(describing: self).capitalized
            }
        }
    }
    
    /// Layout settings
    var settings = Settings()
    
    /// Layout Delegate
    weak var delegate: RelaxLayoutDelegate?
    
    private var contentSize: CGSize = .zero
    private var cache: [Element: [IndexPath: RelaxLayoutAttributes]] = [:]
    private var sectionBodies: [Int: CGSize] = [:]
    private var zIndex: Int = 0
    
    private var contentOffset: CGPoint {
        return collectionView?.contentOffset ?? .zero
    }
    
    private var interitemSpacing: CGFloat { return  settings.interitemSpacing }
    private var lineSpacing: CGFloat { return settings.lineSpacing }
    
    override init() {
        super.init()
        
        // Register reusable view for canvas of a section
        register(RelaxDecorationReusableView.self,
                 forDecorationViewOfKind: Element.sectionCanvas.kind)
        
        // Register separators
        register(RelaxDecorationReusableView.self,
                 forDecorationViewOfKind: Element.topStroke.kind)
        register(RelaxDecorationReusableView.self,
                 forDecorationViewOfKind: Element.leftStroke.kind)
        register(RelaxDecorationReusableView.self,
                 forDecorationViewOfKind: Element.bottomStroke.kind)
        register(RelaxDecorationReusableView.self,
                 forDecorationViewOfKind: Element.rightStroke.kind)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: Overrides
extension RelaxLayout {
    
    override class var layoutAttributesClass: AnyClass {
        return RelaxLayoutAttributes.self
    }
    
//    override class var invalidationContextClass: AnyClass {
//        return RelaxLayoutInvalidationContext.self
//    }
    
    override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if collectionView?.bounds.size != newBounds.size {
            invalidateCache()
        }
        return true
    }
    
//    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
//        guard let context = context as? RelaxLayoutInvalidationContext,
//            let indexPath = context.updatedAttributes?.indexPath,
//            let size = context.updatedAttributes?.size else { return }
//
//        let attributes = cache[.cell]?[indexPath]
//        attributes?.size = size
//        super.invalidateLayout(with: context)
//    }
    
    override func prepare() {
        
        guard
            let collectionView = collectionView,
            collectionView.numberOfSections > 0,
            cache.isEmpty else {
                return
        }
        
        prepareHeader()
        for section in 0 ..< collectionView.numberOfSections {
            prepareSectionHeader(in: collectionView, for: section)
            prepareSectionBody(in: collectionView, for: section)
            prepareSectionFooter(in: collectionView, for: section)
        }
        raiseZIndexes(for: .sectionFooter)
        raiseZIndexes(for: .sectionHeader)
        
        if settings.bringHeaderAlwaysToFront {
            raiseZIndexes(for: .header)
        }
    }
    
    override func layoutAttributesForSupplementaryView(
        ofKind elementKind: String,
        at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        switch elementKind {
        case Element.header.kind:
            return cache[.header]?[indexPath]
            
        case Element.sectionHeader.kind:
            return cache[.sectionHeader]?[indexPath]
            
        case Element.sectionFooter.kind:
            return cache[.sectionFooter]?[indexPath]
            
        default: return nil
        }
    }
    
    override func initialLayoutAttributesForAppearingDecorationElement(
        ofKind elementKind: String,
        at decorationIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesForDecorationView(ofKind: elementKind, at: decorationIndexPath)
    }
    
    override func layoutAttributesForDecorationView(
        ofKind elementKind: String,
        at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        switch elementKind {
        case Element.sectionCanvas.kind:
            return cache[.sectionCanvas]?[indexPath]
            
        case Element.topStroke.kind:
            return cache[.topStroke]?[indexPath]
            
        case Element.leftStroke.kind:
            return cache[.leftStroke]?[indexPath]
            
        case Element.bottomStroke.kind:
            return cache[.bottomStroke]?[indexPath]
            
        case Element.rightStroke.kind:
            return cache[.rightStroke]?[indexPath]
            
        default: return nil
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[.cell]?[indexPath]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let cv = collectionView else { return nil }
        
        var layoutAttributes: [RelaxLayoutAttributes] = []
        
        for (element, info) in cache {
            for (_, attributes) in info {
                update(element, with: attributes, in: rect, for: cv)
                if attributes.frame.intersects(rect) {
                    layoutAttributes.append(attributes)
                }
            }
        }
        return layoutAttributes
    }
    
//    override func shouldInvalidateLayout(
//        forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
//        withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> Bool {
//        return preferredAttributes.size != originalAttributes.size
//    }
    
//    override func invalidationContext(
//        forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
//        withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutInvalidationContext {
//
//        let result = super.invalidationContext(forPreferredLayoutAttributes: preferredAttributes, withOriginalAttributes: originalAttributes)
//        (result as? RelaxLayoutInvalidationContext)?.updatedAttributes = preferredAttributes
//
//        let widthDelta = preferredAttributes.size.width - originalAttributes.size.width
//        let heightDelta = preferredAttributes.size.height - originalAttributes.size.height
//
//        result.contentSizeAdjustment = CGSize(width: widthDelta, height: heightDelta);
//        return result
//
//    }
}

// MARK: Helper methods
extension RelaxLayout {
    
    /// Invalidate data
    func invalidate() {
        invalidateCache()
        contentSize = .zero
        zIndex = 0
        invalidateLayout()
    }
    
    private func invalidateCache() {
        cache.removeAll(keepingCapacity: true)
        sectionBodies = [:]
    }
    
    private func prepareAndCache(element: Element,
                                 with attributes: RelaxLayoutAttributes?) {
        guard let attributes = attributes, attributes.size != .zero else {
            return
        }
        
        attributes.zIndex = zIndex
        zIndex += 1
        
        if cache[element] == nil {
            cache[element] = [:]
        }
        cache[element]?[attributes.indexPath] = attributes
    }
    
    private func raiseZIndexes(for element: Element){
        guard let items = cache[element] else {
            return
        }
        var zIndex = self.zIndex
        for (_, attributes) in items {
            attributes.zIndex = zIndex
            zIndex += 1
        }
    }
    
    private func attributes(forSupplementaryViewOfKind kind: String,
                            with indexPath: IndexPath,
                            size: CGSize,
                            offset: CGPoint = .zero) -> RelaxLayoutAttributes? {
        
        guard let cv = collectionView else {
            return nil
        }
        
        return RelaxLayoutAttributes(
            forSupplementaryViewOfKind: kind,
            with: indexPath).with {
                switch settings.scrollDirection {
                case .horizontal:
                    $0.frame = CGRect(
                        origin: CGPoint(x: contentSize.width + offset.x,
                                        y: cv.center.y - size.height.half + offset.y),
                        size: size
                    )
                    contentSize = CGSize(width: $0.frame.maxX - offset.x,
                                         height: cv.frame.height)
                    
                case .vertical:
                    $0.frame = CGRect(
                        origin: CGPoint(x: cv.center.x - size.width.half + offset.x,
                                        y: contentSize.height + offset.y),
                        size: size
                    )
                    contentSize = CGSize(width: cv.frame.width,
                                         height: $0.frame.maxY - offset.y)
                    
                @unknown default: break
                }
        }
    }
    
    private func attributes(forDecorationViewOfKind kind: String,
                            with indexPath: IndexPath,
                            size: CGSize,
                            offset: CGPoint = .zero,
                            color: UIColor? = nil) -> RelaxLayoutAttributes? {
        
        return RelaxLayoutAttributes(
            forDecorationViewOfKind: kind,
            with: indexPath).with {
                switch settings.scrollDirection {
                case .horizontal:
                    $0.frame = CGRect(
                        origin: CGPoint(x: contentSize.width + offset.x,
                                        y: offset.y),
                        size: size
                    )
                case .vertical:
                    $0.frame = CGRect(
                        origin: CGPoint(x: offset.x,
                                        y: contentSize.height + offset.y),
                        size: size
                    )
                    
                @unknown default: break
                }
                $0.color = color
        }
    }
    
    private func prepareHeader() {
        prepareAndCache(element: .header,
                        with: attributes(
                            forSupplementaryViewOfKind: Element.header.kind,
                            with: IndexPath(item: 0, section: 0),
                            size: settings.headerSize,
                            offset: settings.headerOffset)
        )
    }
    
    private func prepareSectionHeader(in collectionView: UICollectionView, for section: Int) {

        let sectionHeaderSize = delegate?
            .collectionView(collectionView,
                            layout: self,
                            sizeForHeaderInSection: section) ?? settings.sectionHeaderSize
        
        let sectionHeaderCanvasSize = settings.scrollDirection == .horizontal
            ? CGSize(width: sectionHeaderSize.width, height: contentSize.height)
            : CGSize(width: contentSize.width, height: sectionHeaderSize.height)
        
        let sectionHeaderCanvasColor = delegate?.collectionView(collectionView,
                                                                layout: self,
                                                                colorOfHeaderCanvasForSection: section)
            ?? settings.sectionHeaderCanvasColor
        
        prepareAndCache(element: .sectionCanvas,
                        with: attributes(
                            forDecorationViewOfKind: Element.sectionCanvas.kind,
                            with: IndexPath(item: 0, section: section),
                            size: sectionHeaderCanvasSize,
                            color: sectionHeaderCanvasColor)
        )
        prepareAndCache(element: .sectionHeader,
                        with: attributes(
                            forSupplementaryViewOfKind: Element.sectionHeader.kind,
                            with: IndexPath(item: 0, section: section),
                            size: sectionHeaderSize,
                            offset: settings.sectionHeaderOffset)
        )
    }
    
    private func prepareSectionFooter(in collectionView: UICollectionView, for section: Int) {
        
        let sectionFooterSize = delegate?
            .collectionView(collectionView,
                            layout: self,
                            sizeForFooterInSection: section) ?? settings.sectionFooterSize
        
        let sectionFooterCanvasSize = settings.scrollDirection == .horizontal
            ? CGSize(width: sectionFooterSize.width, height: contentSize.height)
            : CGSize(width: contentSize.width, height: sectionFooterSize.height)
        
        let sectionFooterCanvasColor = delegate?.collectionView(collectionView,
                                                                layout: self,
                                                                colorOfFooterCanvasForSection: section)
            ?? settings.sectionFooterCanvasColor
        
        prepareAndCache(element: .sectionCanvas,
                        with: attributes(
                            forDecorationViewOfKind: Element.sectionCanvas.kind,
                            with: IndexPath(item: 2, section: section),
                            size: sectionFooterCanvasSize,
                            color: sectionFooterCanvasColor)
        )
        prepareAndCache(element: .sectionFooter,
                        with: attributes(
                            forSupplementaryViewOfKind: Element.sectionFooter.kind,
                            with: IndexPath(item: 1, section: section),
                            size: sectionFooterSize,
                            offset: settings.sectionFooterOffset)
        )
    }
    
    private func prepareSectionBody(in collectionView: UICollectionView, for section: Int) {
        
        // guard settings.itemSize != .zero else { return }
        
        let cv = collectionView
        let count = cv.numberOfItems(inSection: section)
        
        let canvasAttributes = attributes(
            forDecorationViewOfKind: Element.sectionCanvas.kind,
            with: IndexPath(item: 1, section: section),
            size: CGSize(width: CGFloat.leastNormalMagnitude,
                         height: CGFloat.leastNormalMagnitude),
            color: delegate?.collectionView(cv,
                                            layout: self,
                                            colorOfBodyCanvasForSection: section)
                ?? settings.sectionBodyCanvasColor
        )
        prepareAndCache(element: .sectionCanvas, with: canvasAttributes)
        
        let sectionInsets = delegate?.collectionView(cv,
                                                     layout: self,
                                                     insetsForSection: section)
            ?? settings.sectionInsets
        
        var origin: CGPoint = .zero     // Current item origin
        var nextOrigin: CGPoint = .zero // Origin for next item to start from
        
        var coordinate: (row: Int, column: Int) = (0, 0)
        var bodySize: CGSize = .zero
        
        for i in 0 ..< count {
            let indexPath = IndexPath(item: i, section: section)
            let attributes = RelaxLayoutAttributes(forCellWith: indexPath)
            
            let itemSize = delegate?.collectionView(cv,
                                                   layout: self,
                                                   sizeForItemAt: indexPath) ?? settings.itemSize
            let step = i == count - 1
                ? CGSize(width: itemSize.width, height: itemSize.height)
                : CGSize(width: settings.interitemSpacing + itemSize.width,
                         height: settings.lineSpacing + itemSize.height)
            
            switch settings.scrollDirection {
            case .horizontal:
                
                if i == 0 {
                    origin = CGPoint(x: contentSize.width + sectionInsets.left,
                                     y: sectionInsets.top)
                    nextOrigin.x = origin.x + step.width
                    bodySize = CGSize(width: sectionInsets.left,
                                      height: cv.frame.height)
                    
                    if settings.bodyCanvasRespectsSectionInsets {
                        canvasAttributes?.frame.origin = origin
                    } else {
                        canvasAttributes?.frame.origin = CGPoint(x: contentSize.width, y: 0)
                    }
                } else {
                    bodySize.width += itemSize.width
                    if origin.y + itemSize.height + itemSize.height <= cv.frame.maxY {
//                        origin.y += step.height
                        
                        origin.y = nextOrigin.y
                        nextOrigin.y = origin.y + step.height
                        
                        coordinate.row += 1
                    } else {
                        origin.y = sectionInsets.top
//                        origin.x += step.width
                        
                        origin.x = nextOrigin.x
                        nextOrigin.x = origin.x + step.width
                        
                        coordinate.column += 1
                        bodySize.width += settings.interitemSpacing
                    }
                }
                contentSize = CGSize(width: origin.x + itemSize.width,
                                     height: cv.frame.height)
                if i == count - 1 {
                    contentSize.width += sectionInsets.right
                    bodySize.width += sectionInsets.right
                }
                
                // Size for canvas
                let canvasWidth = settings.bodyCanvasRespectsSectionInsets
                    ? bodySize.width - sectionInsets.leftRight
                    : bodySize.width
                let canvasHeight = settings.bodyCanvasRespectsSectionInsets
                    ? cv.frame.height - sectionInsets.topBottom
                    : cv.frame.height
                
                canvasAttributes?.frame.size = CGSize(width: canvasWidth, height: canvasHeight) //contentSize.width - (canvasAttributes?.frame.minX ?? 0),
                
            case .vertical:
                
                if i == 0 {
                    origin = CGPoint(x: sectionInsets.left,
                                     y: contentSize.height + sectionInsets.top)
                    nextOrigin.y = origin.y + step.height
                    bodySize = CGSize(width: cv.frame.width,
                                      height: itemSize.height + sectionInsets.top)
                    
                    if settings.bodyCanvasRespectsSectionInsets {
                        canvasAttributes?.frame.origin = origin
                    } else {
                        canvasAttributes?.frame.origin = CGPoint(x: 0, y: contentSize.height)
                    }
                } else {
                    bodySize.height += itemSize.height
                    if origin.x + itemSize.width + step.width <= cv.frame.maxX {
//                        origin.x += step.width
                        
                        origin.x = nextOrigin.x
                        nextOrigin.x = origin.x + step.width
                        
                        coordinate.column += 1
                    } else {
                        origin.x = sectionInsets.left
//                        origin.y += step.height
                        
                        origin.y = nextOrigin.y
                        nextOrigin.y = origin.y + step.height
                        
                        coordinate.row += 1
                        bodySize.height += settings.lineSpacing
                    }
                }
                contentSize = CGSize(width: cv.frame.width,
                                     height: origin.y + step.height)
                if i == count - 1 {
                    contentSize.height += sectionInsets.bottom
                    bodySize.height += sectionInsets.bottom
                }
                
                // Size for canvas
                let canvasWidth = settings.bodyCanvasRespectsSectionInsets
                    ? cv.frame.width - sectionInsets.leftRight
                    : cv.frame.width
                let canvasHeight = settings.bodyCanvasRespectsSectionInsets
                    ? bodySize.height - sectionInsets.topBottom
                    : bodySize.height
                
                canvasAttributes?.frame.size = CGSize(width: canvasWidth, height: canvasHeight) //contentSize.height - (canvasAttributes?.frame.minY ?? 0))
                
            @unknown default: break
            }
            sectionBodies[section] = bodySize
            
            attributes.frame = CGRect(origin: origin, size: itemSize)
            prepareAndCache(element: .cell, with: attributes)
            
            // Creation of separators around the cell
            arrangeSeparatorsAroundCell(with: coordinate, with: attributes, step: step, in: cv)
        }
    }
    
    private func arrangeSeparatorsAroundCell(with coordinate: (row: Int, column: Int),
                                             with attributes: RelaxLayoutAttributes,
                                             step: CGSize,
                                             in collectionView: UICollectionView) {
        
        let section = attributes.indexPath.section
        let numberOfItems = collectionView.numberOfItems(inSection: section)
        let cellRect = attributes.frame
        let thickness = settings.separatorWidth
        let anchors = settings.separatorsArrangement
        let style = settings.separatorStyle
        
        let sectionInsets = delegate?.collectionView(collectionView,
                                                     layout: self,
                                                     insetsForSection: section)
            ?? settings.sectionInsets
        
        let isFirstColumn = coordinate.column == 0
        let isFirstRow = coordinate.row == 0
        let isLastColumn: Bool
        let isLastRow: Bool
        
        switch settings.scrollDirection {
        case .horizontal:
            isLastRow = cellRect.maxY + step.height > collectionView.frame.maxY
            isLastColumn = coordinate.column == numberOfItems - 1
            
        case .vertical:
            isLastRow = coordinate.row == numberOfItems - 1
            isLastColumn = cellRect.maxX + step.width > collectionView.frame.maxX
        
        @unknown default:
            isLastRow = false
            isLastColumn = false
        }
        
        var strokes: [Element] = []
        
        switch style {
        case .bordered: strokes = [.topStroke, .leftStroke, .bottomStroke, .rightStroke]
        case .default:
            switch coordinate {
            case (0, 0): strokes = [.topStroke, .leftStroke, .bottomStroke, .rightStroke]
            case (_, 0): strokes = [.leftStroke, .bottomStroke, .rightStroke]
            case (0, _): strokes = [.topStroke, .bottomStroke, .rightStroke]
            default: strokes = [.bottomStroke, .rightStroke]
            }
        }
        
        for stroke in strokes {
            
            var xOffset: CGFloat = 0.0
            var yOffset: CGFloat = 0.0
            
            let separatorAttributes = RelaxLayoutAttributes(
                forDecorationViewOfKind: stroke.kind,
                with: attributes.indexPath).with {
                    
                    switch stroke {
                    case .topStroke:
                        $0.color = settings.separatorColor(collectionView, .top, attributes.indexPath)
                        
                        if anchors.contains(.edgeTop) && (sectionInsets.top > 0 || style == .bordered) {
                            
                            let sepInsets = settings.separatorInsets(collectionView, .top, attributes.indexPath)
                            let sepOffset = settings.separatorOffset(collectionView, .top, attributes.indexPath)
                            
                            yOffset = style == .bordered
                                ? -thickness
                                : isFirstRow
                                ? -max(sectionInsets.top.half + thickness.half, thickness)
                                : -max(lineSpacing.half + thickness.half, thickness)
                            yOffset += sepOffset.y
                            
                            $0.frame = CGRect(
                                x: cellRect.minX + sepInsets.left + sepOffset.x,
                                y: cellRect.minY + yOffset,
                                width: cellRect.size.width - sepInsets.leftRight,
                                height: thickness
                            )
                        }
                        
                    case .leftStroke:
                        $0.color = settings.separatorColor(collectionView, .left, attributes.indexPath)
                        
                        if anchors.contains(.edgeLeft) && (sectionInsets.left > 0 || style == .bordered) {
                            
                            let sepInsets = settings.separatorInsets(collectionView, .left, attributes.indexPath)
                            let sepOffset = settings.separatorOffset(collectionView, .left, attributes.indexPath)
                            
                            xOffset = style == .bordered
                                ? -thickness
                                : isFirstColumn
                                ? -max(sectionInsets.left.half + thickness.half, thickness)
                                : -max(interitemSpacing.half + thickness.half, thickness)
                            xOffset += sepOffset.x
                            
                            $0.frame = CGRect(
                                x: cellRect.minX + xOffset,
                                y: cellRect.minY + sepInsets.top + sepOffset.y,
                                width: thickness,
                                height: cellRect.size.height - sepInsets.topBottom
                            )
                        }
                        
                    case .bottomStroke:
                        $0.color = settings.separatorColor(collectionView, .bottom, attributes.indexPath)
                        
                        if (isLastRow && anchors.contains(.edgeBottom) && sectionInsets.bottom > 0)
                            || (!isLastRow && anchors.contains(.interline)
                                && (lineSpacing > 0 || style == .bordered))  {
                            
                            let sepInsets = settings.separatorInsets(collectionView, .bottom, attributes.indexPath)
                            let sepOffset = settings.separatorOffset(collectionView, .bottom, attributes.indexPath)
                            
                            yOffset = style == .bordered
                                ? 0
                                : isLastRow
                                ? sectionInsets.bottom.half
                                : max(lineSpacing.half - thickness.half, 0)
                            yOffset += sepOffset.y
                            
                            $0.frame = CGRect(
                                x: cellRect.minX + sepInsets.left + sepOffset.x,
                                y: cellRect.maxY + yOffset,
                                width: cellRect.size.width - sepInsets.leftRight,
                                height: thickness
                            )
                        }
                        
                    case .rightStroke:
                        $0.color = settings.separatorColor(collectionView, .right, attributes.indexPath)
                        
                        if (isLastColumn && anchors.contains(.edgeRight) && sectionInsets.right > 0)
                            || (!isLastColumn && anchors.contains(.interitem)
                                && (interitemSpacing > 0 || style == .bordered)) {
                            
                            let sepInsets = settings.separatorInsets(collectionView, .right, attributes.indexPath)
                            let sepOffset = settings.separatorOffset(collectionView, .right, attributes.indexPath)
                            
                            xOffset = style == .bordered
                                ? 0
                                : isLastColumn
                                ? sectionInsets.right.half
                                : max(interitemSpacing.half - thickness.half, 0)
                            xOffset += sepOffset.x
                            
                            $0.frame = CGRect(
                                x: cellRect.maxX + xOffset,
                                y: cellRect.minY + sepInsets.top + sepOffset.y,
                                width: thickness,
                                height: cellRect.size.height - sepInsets.topBottom
                            )
                        }
                        
                    default: break
                    }
            }
            prepareAndCache(element: stroke, with: separatorAttributes)
        }
    }
    
    private func update(_ element: Element,
                        with attributes: RelaxLayoutAttributes,
                        in rect: CGRect,
                        for collectionView: UICollectionView) {
        
        attributes.parallax = .identity
        attributes.transform = .identity
        
        switch element {
        case .cell:
            if settings.isParallaxInCellsEnabled {
                let itemSize = attributes.frame.size
                let cvFrame = collectionView.frame
                let distFromCenter = CGSize(
                    width: attributes.center.x - contentOffset.x - cvFrame.width.half,
                    height: attributes.center.y - contentOffset.y - cvFrame.height.half
                )
                let maxGab = settings.maxParallaxGab
                let parallax = CGPoint(
                    x: -(maxGab * distFromCenter.width) / (itemSize.width.half + cvFrame.width.half),
                    y: -(maxGab * distFromCenter.height) / (itemSize.height.half + cvFrame.height.half)
                )
                let adjustedParallax = CGPoint(
                    x: min(max(-maxGab, parallax.x), maxGab),
                    y: min(max(-maxGab, parallax.y), maxGab)
                )
                attributes.parallax = CGAffineTransform(translationX: adjustedParallax.x,
                                                        y: adjustedParallax.y)
            }
            
        case .header:
            let headerSize = settings.headerSize
            
            // Pinning
            guard !settings.headerPinsToVisibleBounds else {
                attributes.transform = CGAffineTransform(
                    translationX: min(contentSize.width,
                                      max(0,
                                          contentOffset.x - attributes.frame.origin.x)
                    ),
                    y: min(contentSize.height,
                           max(0,
                               contentOffset.y - attributes.frame.origin.y)
                    )
                )
                return
            }
            
            // Stretching
            if settings.isHeaderStretchy {
                let adjustedSize = CGPoint(
                    x: min(rect.width,
                           max(headerSize.width, headerSize.width - contentOffset.x)),
                    y: min(rect.height,
                           max(headerSize.height, headerSize.height - contentOffset.y))
                )
                let scaleFactor = CGPoint(x: adjustedSize.x / headerSize.width,
                                          y: adjustedSize.y / headerSize.height)
                let deltaX = (adjustedSize.x - headerSize.width).half
                let deltaY = (adjustedSize.y - headerSize.height).half
                let scale: CGAffineTransform
                
                switch settings.scrollDirection {
                case .horizontal:
                    scale = CGAffineTransform(scaleX: scaleFactor.x, y: scaleFactor.x)
                case .vertical:
                    scale = CGAffineTransform(scaleX: scaleFactor.y, y: scaleFactor.y)
                @unknown default:
                    scale = CGAffineTransform(scaleX: 0, y: 0)
                }
                let translation = CGAffineTransform(
                    translationX: min(contentOffset.x, headerSize.width) + deltaX,
                    y: min(contentOffset.y, headerSize.height) + deltaY
                )
                attributes.transform = scale.concatenating(translation)
            }
            
            // Parallax effect
            if settings.headerShiftRate > 0 {
                if settings.isHeaderStretchy {
                    let deltaX = max(0, contentOffset.x) * settings.headerShiftRate
                    let deltaY = max(0, contentOffset.y) * settings.headerShiftRate
                    attributes.transform.tx -= deltaX
                    attributes.transform.ty -= deltaY
                } else {
                    let adjustedSize = CGPoint(
                        x: max(0, min(rect.width, headerSize.width - contentOffset.x)),
                        y: max(0, min(rect.height, headerSize.height - contentOffset.y))
                    )
                    let deltaX = (adjustedSize.x - headerSize.width) * settings.headerShiftRate
                    let deltaY = (adjustedSize.y - headerSize.height) * settings.headerShiftRate
                    attributes.transform.tx = min(contentOffset.x, headerSize.width) + deltaX
                    attributes.transform.ty = min(contentOffset.y, headerSize.height) + deltaY
                }
            }
            
            // Overlay Alpha
            let alpha = settings.scrollDirection == .horizontal
                ? contentOffset.x / headerSize.width
                : contentOffset.y / headerSize.height
            attributes.overlayAlpha = min(settings.headerOverlayMaxAlpha, alpha)
            
        case .sectionHeader:
            if settings.sectionHeadersPinToVisibleBounds,
                let bodySize = sectionBodies[attributes.indexPath.section]  {
                
                let offset = settings.sectionHeaderOffset
                let pinOffset = settings.pinPointOffsetForSectionHeader
                    ?? CGPoint(x: offset.x,
                               y: collectionView.superview?.layoutMargins.top ?? 0.0)
                
//                let bodySize = bodySizeOfSection(attributes.indexPath.section,
//                                                 in: collectionView)
                
                attributes.transform = CGAffineTransform(
                    translationX: min(bodySize.width - offset.x,
                                      max(pinOffset.x - offset.x,
                                          contentOffset.x - attributes.frame.origin.x + pinOffset.x)
                    ),
                    y: min(bodySize.height - offset.y + pinOffset.y,
                           max(pinOffset.y - offset.y,
                               contentOffset.y - attributes.frame.origin.y + pinOffset.y)
                    )
                )
            }
            
        case .sectionFooter:
            if settings.sectionFootersPinToVisibleBounds,
                let bodySize = sectionBodies[attributes.indexPath.section]  {
                
                let cv = collectionView
                let offset = settings.sectionFooterOffset
                let pinOffset = settings.pinPointOffsetForSectionFooter
                    ?? CGPoint(x: offset.x,
                               y: -(cv.superview?.layoutMargins.bottom ?? 0.0))
                
                let sectionHeaderSize = delegate?
                    .collectionView(collectionView,
                                    layout: self,
                                    sizeForHeaderInSection: attributes.indexPath.section)
                    ?? settings.sectionHeaderSize
                
                let sectionFooterSize = attributes.size
//                let bodySize = bodySizeOfSection(attributes.indexPath.section, in: cv)
                let sectionSize = sectionHeaderSize + sectionFooterSize + bodySize
                
                attributes.transform = CGAffineTransform(
                    translationX: max(-sectionSize.width + cv.frame.maxX + pinOffset.x - offset.x,
                                      min(-offset.x,
                                          contentOffset.x - attributes.frame.origin.x
                                            + cv.frame.maxX - sectionFooterSize.width + pinOffset.x)
                    ),
                    y: max(-sectionSize.height + cv.frame.maxY + pinOffset.y - offset.y,
                           min(-offset.y,
                               contentOffset.y - attributes.frame.origin.y
                                + cv.frame.maxY - sectionFooterSize.height + pinOffset.y)
                    )
                )
            }
            
        default: break
        }
    }
}
