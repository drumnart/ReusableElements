//
//  SegmentedBar.swift
//
//  Created by Sergey Gorin on 23/10/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

class SegmentedBar: UIView {
    
    typealias SelectionHandler = (_ item: UIView, _ oldIndex: Int, _ newIndex: Int) -> ()
    typealias ShouldSelectHandler = (_ item: UIView, _ index: Int) -> Bool
    
    lazy var contentView = UIStackView().with {
        $0.alignment = .fill
    }
    
    lazy var borderView = UIView().with {
        $0.layer.cornerRadius = edgeCornerRadius
        $0.layer.borderWidth = delimiterWidth
        $0.layer.borderColor = delimiterColor.cgColor
        $0.isUserInteractionEnabled = false
    }
    
    lazy var selectorView = UIView().with {
        $0.isHidden = true
        $0.layer.borderWidth = 2.0
        $0.layer.borderColor = selectorBorderColor.cgColor
    }
    
    var edgeCornerRadius: CGFloat = 10.0
    var delimiterWidth: CGFloat = 1.0
    var delimiterColor: UIColor = .lightGray
    var selectorBorderColor: UIColor = .black
    
    /// Whether animate or not initial appearance of item selector. Default is false.
    var shouldAnimateSelectorAppearance: Bool = false
    
    var numberOfItems: () -> Int = { 0 }
    var itemBuilder: ((_ bar: SegmentedBar, _ index: Int) -> UIView)?
    
    private(set) var selectedIndex: Int = -1 {
        didSet {
            selectorView.isHidden = selectedIndex < 0
        }
    }
    
    private(set) var items: [UIView] = []
    
    private var selectionHandler: SelectionHandler?
    private var shouldSelectHandler: ShouldSelectHandler? = { _,_ in true }
    
    private var itemsCount: Int {
        return items.count
    }
    
    private lazy var itemSize = CGSize(
        width: (bounds.width - delimiterWidth * CGFloat(itemsCount - 1)) /? CGFloat(itemsCount),
        height: bounds.height
    )
    
    private var selectorCenterXConstr: NSLayoutConstraint!
    private var selectorWidthConstr: NSLayoutConstraint!
    
    override var bounds: CGRect {
        didSet {
            layout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        
        xt.addSubviews(contentView, borderView, selectorView)
        contentView.xt.pinEdges()
        borderView.xt.pinEdges()
        
        selectorView.xt.layout {
            $0.pinEdges([.top, .bottom])
            selectorCenterXConstr = $0.centerX(equalTo: $1.xt.leading, constant: 0)
            selectorWidthConstr = $0.width(0)
        }
    }
    
    func setItems(_ items: [UIView]) {
        
        contentView.arrangedSubviews.forEach { contentView.removeArrangedSubview($0) }
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        self.items = items
                
        items.enumerated().forEach { (index, item) in
            guard xt.getSubview(withId: index) == nil else { return }
                        
            item.xt.setId(index)
            
            if index == 0 {
                item.layer.cornerRadius = edgeCornerRadius
                item.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            }
            
            if index == items.count - 1 {
                item.layer.cornerRadius = edgeCornerRadius
                item.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            }
            
            item.xt.onTap { [unowned self] tap in
                self.onDidTap(tap)
            }
            
            contentView.addArrangedSubview(item)
            
            if index < items.endIndex - 1 {
                
                let delimiter = UIView().with {
                    $0.backgroundColor = delimiterColor
                    $0.xt.width(delimiterWidth)
                }
                
                contentView.addArrangedSubview(delimiter)
            }
        }
        
        layout()
    }
    
    // Selection callback
    func onDidSelect(_ closure: SelectionHandler?) {
        selectionHandler = closure
    }
    
    // Whether selection made by gesture is allowed for item
    func shouldSelect(_ closure: ShouldSelectHandler?) {
        shouldSelectHandler = closure
    }
    
    // Select item programmatically
    func selectItem(at index: Int,
                    withAnimationDuration duration: TimeInterval = 0.8,
                    delay: TimeInterval = 0.0,
                    springDamping: CGFloat = 0.8,
                    initialVelocity: CGFloat = 1.0) {
        guard index < items.count, index != selectedIndex else { return }
        
        let oldIndex = selectedIndex
        selectedIndex = index
        
        let shouldAnimate = oldIndex >= 0 || shouldAnimateSelectorAppearance
        
        shiftSelector(
            to: index,
            withAnimationDuration: shouldAnimate ? duration : 0,
            delay: delay,
            springDamping: springDamping,
            initialVelocity: initialVelocity
        )
    }
    
    private func shiftSelector(to index: Int,
                               withAnimationDuration duration: TimeInterval,
                               delay: TimeInterval,
                               springDamping: CGFloat,
                               initialVelocity: CGFloat) {
        
        guard let item = items[safe: index] else { return }
        
        selectorWidthConstr.constant = itemSize.width + delimiterWidth * 2
        selectorCenterXConstr.constant = item.center.x
        
        if index == 0 || index == self.items.count - 1 {
            selectorView.layer.maskedCorners = item.layer.maskedCorners
        } else {
            selectorView.layer.maskedCorners = []
        }
        
        if duration > 0 {
            UIView.animate(
                withDuration: duration,
                delay: delay,
                usingSpringWithDamping: springDamping,
                initialSpringVelocity: initialVelocity,
                options: [],
                animations: {
                    self.selectorView.layer.cornerRadius = item.layer.cornerRadius
                    self.layoutIfNeeded()
            }) { _ in }
        } else {
            selectorView.layer.cornerRadius = item.layer.cornerRadius
        }
    }
    
    private func layout() {
        items.forEach {
            $0.xt.width(.equal, to: itemSize.width)
        }
        
        layoutIfNeeded()
    }
    
    private func onDidTap(_ recognizer: UITapGestureRecognizer) {
        guard let nextItem = recognizer.view else { return }
        
        let newIndex = items.firstIndex { $0 == nextItem } ?? 0
        
        guard shouldSelectHandler?(nextItem, newIndex) == true else { return }
        
        let oldIndex = selectedIndex
        
        selectItem(at: newIndex)
        selectionHandler?(nextItem, oldIndex, selectedIndex)
    }
}
