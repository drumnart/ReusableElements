//
//  CarouselView.swift
//
//  Created by Sergey Gorin on 26/03/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

protocol CarouselViewDataSource: NSObjectProtocol {
    func numberOfItems(in carouselView: CarouselView) -> Int
    func carouselView(_ carouselView: CarouselView,
                      cellForItemAt index: Int) -> CarouselCollectionViewCell
}

protocol CarouselViewDelegate: NSObjectProtocol {
    func carouselView(_ carouselView: CarouselView, didSelectItemAt index: Int)
}

// Public interface

// MARK: - Timer
extension CarouselView {
    
    func pauseTimer() {
        if autoSlidingInterval > 0 {
            timerController.pause()
        }
    }
    
    func stopTimer() {
        if autoSlidingInterval > 0 {
            timerController.stop()
        }
    }
    
    func resumeTimer() {
        if canAutoSlide {
            switch timerController.state {
            case .stopped: timerController.start(with: autoSlidingInterval)
            case .iddle: timerController.resume()
            case .running: break
            }
        }
    }
    
    func next() {
        guard let _ = superview, let _ = window, numberOfItems > 1, !collectionView.isTracking else { return }
        
        let nextPoint = scrollDirection == .horizontal
            ? collectionView.contentOffset + CGPoint(x: carouselLayout.itemSpread, y: 0)
            : collectionView.contentOffset + CGPoint(x: 0, y: carouselLayout.itemSpread)
        
        guard let indexPath = collectionView.indexPathForItem(at: nextPoint) else { return }
        let newOffset = carouselLayout.preferredContentOffset(for: indexPath)
        
//        DispatchQueue.main.async {
//            UIView.animate(
//                withDuration: self.autoSlidingDuration,
//                delay: 0.0,
//                options: self.autoSlidingAnimationOptions,
//                animations: {
//                    self.collectionView.contentOffset = newOffset
//                }, completion: nil
//            )
//        }
        collectionView.setContentOffset(newOffset, animated: true)
    }
    
    // Set Current Page programmatically
    func setPage(_ page: Int, animated: Bool = false) {
        guard page >= 0 && page < numberOfItems else  { return }
        
        currentPage = page
    
        let nextPoint = scrollDirection == .horizontal
            ? CGPoint(x: CGFloat(page) * carouselLayout.itemSpread, y: 0)
            : CGPoint(x: 0, y: CGFloat(page) * carouselLayout.itemSpread)
        
        guard let indexPath = collectionView.indexPathForItem(at: nextPoint) else { return }
        let newOffset = carouselLayout.preferredContentOffset(for: indexPath)
        
        let shouldAnimate = window != nil ? animated : false
        collectionView.setContentOffset(newOffset, animated: shouldAnimate)
    }
}

// MARK: - Cells Building
extension CarouselView {
    
    /// Realoads all collection view's data
    func reload() {
        updatePagesLbl()
        carouselLayout.shouldPrepare = true
        collectionView.reloadData()
    }
    
    /// Register class-based UICollectioniewCell
    /// Example: collectionView.register(CustomCollectionViewCell.self)
    func register<T: UICollectionViewCell>(_: T.Type,
                                           withReuseId reuseId: ReuseId? = nil) {
        collectionView.register(T.self,
                                forCellWithReuseIdentifier: reuseId?.rawValue ?? T.reuseIdentifier)
    }
    
    /// Register a bunch of nib-based or class-based cells of type/subtype UICollectionViewCell
    /// - Parameters: types - array of cells' classes
    /// - Example: collectionView.register([CustomCollectionViewCell.self])
    func register<T: UICollectionViewCell>(_ types: [T.Type]) {
        types.forEach {
            if let cellClass = $0 as? NibReusable.Type {
                collectionView.register(cellClass.nib,
                                        forCellWithReuseIdentifier: $0.reuseIdentifier)
            } else {
                collectionView.register($0.self,
                                        forCellWithReuseIdentifier: $0.reuseIdentifier)
            }
        }
    }
    
    /// Dequeue custom UICollectionViewCell
    /// Example: let cell: CustomCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
    func dequeueCell<T: UICollectionViewCell>(_: T.Type = T.self,
                                              withReuseId reuseId: ReuseId? = nil,
                                              at index: Int) -> T {
        let reuseId = reuseId?.rawValue ?? T.reuseIdentifier
        let indexPath = IndexPath(item: index,
                                  section: collectionViewDataSource.sectionToDequeue)
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId,
                                                            for: indexPath) as? T else {
                                                                fatalError("Failed to dequeue cell with reuse identifier \(reuseId). Verify id in XIB/Storyboard.")
        }
        return cell
    }
}

class CarouselView: UIView {
    
    weak var dataSource: CarouselViewDataSource?
    weak var delegate: CarouselViewDelegate?
    
    var scrollDirection: UICollectionView.ScrollDirection = .horizontal {
        didSet {
            carouselLayout.scrollDirection = scrollDirection
        }
    }
    
    var isInfinite: Bool = true {
        didSet {
            carouselLayout.isInfinite = isInfinite
            collectionView.reloadData()
        }
    }
    
    var autoSlidingInterval: TimeInterval = 0.0 {
        didSet {
            stopTimer()
            if autoSlidingInterval > 0 {
                resumeTimer()
            }
        }
    }
    
    var autoSlidingDuration: TimeInterval = 1
    var autoSlidingAnimationOptions: UIView.AnimationOptions = [.curveEaseOut]
    
    var interitemSpacing: CGFloat = 0 {
        didSet {
            carouselLayout.interitemSpacing = interitemSpacing
        }
    }
    
    var itemSize: CGSize = .zero {
        didSet {
            carouselLayout.itemSize = itemSize
            carouselLayout.forcePrepare(resetContentOffset: false)
        }
    }
    
    var isPagingEnabled: Bool = false {
        didSet {
            collectionView.isPagingEnabled = isPagingEnabled
        }
    }
    
    var isPagesViewHidden: Bool = true {
        didSet {
            if isPagesViewHidden {
                pagesView.isHidden = true
            } else {
                pagesView.isHidden = numberOfItems > 1
            }
        }
    }
    
    var minVelocityForTargetOffset: CGFloat = 0.2 {
        didSet {
            carouselLayout.minVelocityForTargetOffset = minVelocityForTargetOffset
        }
    }
    
    var pagesViewHeight: CGFloat = 20.0 {
        didSet {
            pagesViewHeightConstr?.constant = pagesViewHeight
        }
    }
    
    private var pagesViewHeightConstr: NSLayoutConstraint!
    
    private(set) var currentPage: Int = 0 {
        didSet {
            guard currentPage != oldValue else { return }
            updatePagesLbl()
            pagingClosure?(currentPage)
            if !canAutoSlide {
                pauseTimer()
            }
        }
    }
    
    private(set) lazy var carouselLayout = CarouselViewLayout()
    private(set) lazy var collectionView = UICollectionView(frame: .zero,
                                                            collectionViewLayout: carouselLayout).with {
        if #available(iOS 10.0, *) {
            $0.isPrefetchingEnabled = false
        }
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        }
        $0.scrollsToTop = false
        $0.decelerationRate = .fast
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.dataSource = collectionViewDataSource
        $0.delegate = collectionViewDelegate
        $0.backgroundColor = .clear
    }
    
    lazy var pagesLbl: UILabel = UILabel().with {
        $0.font = .regular(12)
        $0.textColor = .tbxWhite
    }
    
    lazy var pagesView = UIView().with {
        $0.isHidden = true
        $0.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
        $0.xt.round(cornerRadius: pagesViewHeight.half)
        $0.xt.rasterize()
    }
    
    private lazy var collectionViewDataSource = CollectionViewDataSource(self)
    private lazy var collectionViewDelegate = CollectionViewDelegate(self)
    
    private var contentOffset: CGPoint {
        switch carouselLayout.scrollDirection {
        case .horizontal:
            return CGPoint(x: fmod(collectionView.contentOffset.x / carouselLayout.itemSpread, CGFloat(numberOfItems)),
                           y: 0)
            
        case .vertical:
            return CGPoint(x: 0,
                           y: fmod(collectionView.contentOffset.y / carouselLayout.itemSpread, CGFloat(numberOfItems)))
        @unknown default:
            return .zero
        }
    }
    
    private var canAutoSlide: Bool {
        return numberOfItems > 1
            && autoSlidingInterval > 0
            && (isInfinite || currentPage < numberOfItems - 1)
    }
    
    fileprivate var numberOfItems: Int {
        return collectionViewDataSource.collectionView(collectionView, numberOfItemsInSection: 0)
    }
    fileprivate var numberOfSections: Int {
        return collectionViewDataSource.numberOfSections(in: collectionView)
    }
    
    private lazy var timerController = TimerController().onDidTick { _ in
        self.next()
    }
    
    private var pagingClosure: ((_ page: Int) -> Void)?
    
    fileprivate var numberOfItemsClosure: (CarouselView) -> Int = { _ in 0 }
    fileprivate var cellBuilderClosure: (CarouselView, Int) -> CarouselCollectionViewCell = { _, _ in
        return CarouselCollectionViewCell()
    }
    fileprivate var didSelectClosure: (CarouselView, Int) -> () = { _,_ in }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    deinit {
        timerController.stop()
        collectionView.dataSource = nil
        collectionView.delegate = nil
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        if newWindow != nil {
            if xt.isVisible() {
                resumeTimer()
            }
        } else {
            pauseTimer()
        }
    }
    
    func configure() {
        
        xt.addSubviews(collectionView, pagesView)
        pagesView.addSubview(pagesLbl)
        
        collectionView.xt.pinEdges()
        
        pagesLbl.xt.pinEdges(insets: UIEdgeInsets(top: 2, left: 11, bottom: 2, right: 11))
        pagesView.xt.layout {
            $0.bottom(-16)
            $0.trailing(-16)
            pagesViewHeightConstr = $0.height(pagesViewHeight)
        }
    }
    
    func updateCurrentPage() {
        if numberOfItems > 0 {
            switch carouselLayout.scrollDirection {
            case .horizontal: currentPage = lround(Double(contentOffset.x)) % numberOfItems
            case .vertical: currentPage = lround(Double(contentOffset.y)) % numberOfItems
            @unknown default: break
            }
        }
    }
    
    func numberOfItems(_ closure: @escaping (CarouselView) -> Int) {
        numberOfItemsClosure = closure
    }
    
    func cellBuilder(_ closure: @escaping (CarouselView, Int) -> CarouselCollectionViewCell) {
        cellBuilderClosure = closure
    }
    
    func onDidSelectItem(_ closure: @escaping (CarouselView, Int) -> ()) {
        didSelectClosure = closure
    }
    
    func onPageDidChange(_ closure: ((Int) -> Void)?) {
        self.pagingClosure = closure
    }
    
    func updatePagesLbl() {
        let count = numberOfItems
        pagesView.isHidden = count < 2 || isPagesViewHidden
        pagesLbl.text = "\(currentPage + 1)/\(count)"
    }
}

/// Carousel Collection View Datasource
fileprivate class CollectionViewDataSource: NSObject, UICollectionViewDataSource {
    private weak var carouselView: CarouselView!
    
    fileprivate var sectionToDequeue: Int = 0
    
    init(_ carouselView: CarouselView) {
        self.carouselView = carouselView
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let numberOfItems = self.collectionView(collectionView, numberOfItemsInSection: 0)
        guard numberOfItems > 0 else { return 0 }
        return carouselView.isInfinite && numberOfItems > 1
            ? Int(Int16.max) / numberOfItems
            : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return carouselView.dataSource?.numberOfItems(in: carouselView)
            ?? carouselView.numberOfItemsClosure(carouselView)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        sectionToDequeue = indexPath.section
        return carouselView.dataSource?.carouselView(carouselView,
                                                     cellForItemAt: indexPath.item)
            ?? carouselView.cellBuilderClosure(carouselView, indexPath.item)
    }
}

/// Carousel Collection View Delegate
fileprivate class CollectionViewDelegate: NSObject, UICollectionViewDelegate {
    private weak var carouselView: CarouselView!
    
    init(_ carouselView: CarouselView) {
        self.carouselView = carouselView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.item % carouselView.numberOfItems
        carouselView.delegate?.carouselView(carouselView, didSelectItemAt: indexPath.item)
            ?? carouselView.didSelectClosure(carouselView, index)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        carouselView.pauseTimer()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        carouselView.updateCurrentPage()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        carouselView.resumeTimer()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    }
}
