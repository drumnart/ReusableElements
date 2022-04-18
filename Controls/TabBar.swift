//
//  TabBar.swift
//
//  Created by Sergey Gorin on 27/03/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

class TabBar: UIStackView {
    
    struct Settings {
        var spacing: CGFloat = 0.0
        var font: UIFont = .regular(14)
        var selectedFont: UIFont = .regular(14)
        var itemTextColor: UIColor = .tbxBlueGrey
        var selectedTextColor: UIColor = .tbxBlack
        var indicatorBottomInset: CGFloat = 0.0
        var animationDuration: TimeInterval = 0.2
        var indicatorHeight: CGFloat = 2.0
        var inndicatorWidth: CGFloat?
        var indicatorColor: UIColor = .tbxBlackTint
        var bottomSeparatorColor: UIColor = .tbxVeryLightPink
        var bottomSeparatorThickness: CGFloat = 0.5
        var transformLabelsScaleEnabled: Bool = false
    }
    
    var settings = Settings() {
        didSet {
           pointerView.backgroundColor = settings.indicatorColor
        }
    }
    
    var titles: [String] = [] {
        didSet {
            buildLabels()
        }
    }
    
    lazy var backgroundView = UIView()
    
    lazy var bottomBorder = LineView(
        lineColor: settings.bottomSeparatorColor,
        lineThickness: settings.bottomSeparatorThickness
    )
    
    var isBottomBorderHidden = true {
        didSet {
            bottomBorder.isHidden = isBottomBorderHidden
        }
    }
    
    var pointerView: UIView!
    
    private var items: [UIView] = []
    
    typealias SelectionHandler = (_ label: UILabel, _ oldIndex: Int, _ newIndex: Int) -> ()
    private var selectionHandler: SelectionHandler?
    
    private(set) var selectedIndex: Int = 0
    
    override var bounds: CGRect {
        didSet {
            buildLabels()
            selectItem(at: selectedIndex)
        }
    }
    
    convenience init(titles: [String], settings: Settings = Settings()) {
        self.init(frame: .zero)
        self.titles = titles
        self.settings = settings
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureViews()
    }
    
//    override func layoutSubviews() {
//        updateIndicatorPosition()
//    }
    
    func onDidSelect(_ closure: SelectionHandler?) {
        selectionHandler = closure
    }
    
    func selectItem(at index: Int) {
        guard index != selectedIndex,
            let label = xt.getSubview(withId: "\(index)") as? UILabel else {
                updateIndicatorPosition()
                return
        }
        
        let prevLabel = xt.getSubview(withId: "\(selectedIndex)") as? UILabel
        
        label.textColor = self.settings.selectedTextColor
        prevLabel?.textColor = self.settings.itemTextColor
        
        label.font = self.settings.selectedFont
        prevLabel?.font = self.settings.font
        
        selectedIndex = index
        
        if settings.transformLabelsScaleEnabled {
            
            let scale = settings.font.pointSize / settings.selectedFont.pointSize
            label.transform = label.transform.scaledBy(x: scale, y: scale)
            prevLabel?.transform = prevLabel?.transform.scaledBy(x: 1/scale, y: 1/scale) ?? .identity
        
            UIView.animate(
                withDuration: settings.animationDuration,
                delay: 0,
                options: [],
                animations: {
                    label.transform = label.transform.scaledBy(x: 1/scale, y: 1/scale)
                    prevLabel?.transform = prevLabel?.transform.scaledBy(x: scale, y: scale) ?? .identity
            }, completion: nil)
        }
        
        self.updateIndicatorPosition()
    }
    
    func updateIndicatorPosition() {
        pointerView.frame.size.height = settings.indicatorHeight
        pointerView.frame.origin.y = frame.height
            - settings.indicatorHeight
            - settings.indicatorBottomInset
        shiftIndicator()
    }
    
    func configureViews() {
        
        pointerView = UIView().with {
            $0.frame.size.height = settings.indicatorHeight
            $0.frame.origin.y = frame.height
                - settings.indicatorHeight
                - settings.indicatorBottomInset
            $0.backgroundColor = settings.indicatorColor
        }
        
        axis = .horizontal
        distribution = .fillEqually
        alignment = .center
        spacing = settings.spacing
        addSubview(backgroundView)
        addSubview(pointerView)
        addSubview(bottomBorder)
        
        bottomBorder.isHidden = true
        
        backgroundView.xt.pinEdges()
        bottomBorder.xt.layout {
            $0.pinEdges([.left, .bottom, .right])
            $0.height(bottomBorder.lineThickness)
        }
    }
    
    func buildLabels() {
        items.forEach { $0.removeFromSuperview() }
        items = []
        titles.enumerated().forEach { (index, title) in
            guard xt.getSubview(withId: "\(index)") == nil else { return }
            
            let label = WidenTouchAreaLabel().with {
                $0.xt.onTap { [unowned self] tap in
                    self.onDidTap(tap)
                }
                $0.accessibilityIdentifier = String(index)
                $0.numberOfLines = 1
                $0.font = index == selectedIndex
                    ? settings.selectedFont
                    : settings.font
                $0.textColor = index == selectedIndex
                    ? settings.selectedTextColor
                    : settings.itemTextColor
                $0.textAlignment = .center
                $0.text = title
                sizeToFit()
            }
            items.append(label)
            addArrangedSubview(label)
            layoutIfNeeded()
        }
    }
    
    private func shiftIndicator() {
        guard let currentLabel = xt.getSubview(withId: "\(selectedIndex)") else { return }
        
        UIView.animate(withDuration: settings.animationDuration,
                       delay: 0.0,
                       options: [.curveEaseInOut],
                       animations: {
                        if let customWidth = self.settings.inndicatorWidth {
                            self.pointerView.frame.origin.x = currentLabel.frame.center.x - customWidth.half
                            self.pointerView.frame.size.width = customWidth
                        } else {
                            self.pointerView.frame.origin.x = currentLabel.frame.minX
                            self.pointerView.frame.size.width = currentLabel.frame.width
                        }
        }) { _ in }
    }
    
    private func onDidTap(_ recognizer: UITapGestureRecognizer) {
        guard let nextLabel = (recognizer.view as? UILabel) else { return }
        
        let newIndex = Int(nextLabel.accessibilityIdentifier ?? "0") ?? 0
        let oldIndex = selectedIndex
        selectItem(at: newIndex)
        selectionHandler?(nextLabel, oldIndex, selectedIndex)
    }
}

extension TabBar {
    
    enum Place {
        case next, previous
    }
    
    func `switch`(to place: Place = .next) {
        
        let numberOfItems = titles.count
        guard numberOfItems > 1 else { return }
        
        let newIndex: Int
        switch place {
        case .next: newIndex = selectedIndex + 1 < numberOfItems
            ? (selectedIndex + 1)
            : 0
            
        case .previous: newIndex = selectedIndex - 1 > 0
            ? (selectedIndex - 1)
            : (numberOfItems - 1)
        }
        
        guard
            let selectedLabel = xt.getSubview(withId: "\(newIndex)") as? UILabel else {
                return
        }
        
        let oldIndex = selectedIndex
        selectedIndex = newIndex
        selectionHandler?(selectedLabel, oldIndex, selectedIndex)
        shiftIndicator()
    }
    
    func sync(with scrollView: UIScrollView?) {
        scrollView?
            .panGestureRecognizer
            .addTarget(self, action: #selector(handlePan(gesture:)))
    }
    
    @objc private func handlePan(gesture: UIPanGestureRecognizer) {
        guard let scrollView = gesture.view as? UIScrollView else { return }
        let tr = gesture.translation(in: scrollView)
        //        print("translation: ", tr)
        print("velocity: ", gesture.velocity(in: scrollView))
        
        //let maxDistance = scrollView.contentSize.width //- scrollView .frame.width
        let ratio = (scrollView.frame.width - bounds.width) / scrollView.frame.width
        pointerView.center.x -= tr.x / ratio
    }
}
