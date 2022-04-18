//
//  CountControl.swift
//
//  Created by Sergey Gorin on 15/04/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

class CountControl: UIView {
    
    enum ActionType {
        case increment
        case decrement
    }
    
    typealias ActionHandler = (_ count: Int, _ action: ActionType) -> ()
    
    var actionHandler: ActionHandler?
    
    private(set) lazy var incrementButton = WidenTouchAreaButton(type: .custom).with {
        $0.setImage(Asset.CountControl.add.image, for: .normal)
        $0.setImage(Asset.CountControl.addDisabled.image, for: .disabled)
        $0.onAction { [unowned self] _ in self.incrementAction() }
    }
    
    private(set) lazy var decrementButton = WidenTouchAreaButton(type: .custom).with {
        $0.setImage(Asset.CountControl.reduce.image, for: .normal)
        $0.setImage(Asset.CountControl.reduceDisabled.image, for: .disabled)
        $0.onAction { [unowned self] _ in self.decrementAction() }
    }
    
    private(set) lazy var countLabel = PaddingLabel().with {
        $0.numberOfLines = 1
        $0.font = .systemFont(ofSize: 14)
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.5
        $0.textColor = .black
        $0.textAlignment = .center
        $0.text = String(minimumValue)
        
        $0.layer.shouldRasterize = true
        $0.layer.rasterizationScale = UIScreen.main.scale
    }
    
    private(set) lazy var stackView = UIStackView().with {
        $0.isLayoutMarginsRelativeArrangement = true
        $0.distribution = .fill
        $0.alignment = .center
        $0.spacing = 6
        $0.addArrangedSubview(decrementButton)
        $0.addArrangedSubview(countLabel)
        $0.addArrangedSubview(incrementButton)
    }
    
    private var incWidthConstraint: NSLayoutConstraint!
    private var incHeightConstraint: NSLayoutConstraint!
    private var decWidthConstraint: NSLayoutConstraint!
    private var decHeightConstraint: NSLayoutConstraint!
    private var countLblWidthConstraint: NSLayoutConstraint!
    private var countLblHeightConstraint: NSLayoutConstraint!
    
    private let lock = NSLock()
    
    var activeStateColor: UIColor = .tbxBrownGrey {
        didSet {
            updateAppearance()
        }
    }
    
    var inactiveStateColor: UIColor = .tbxLightBlueGrey {
        didSet {
            updateAppearance()
        }
    }
    
    var activeCountColor: UIColor = .tbxBlackTint {
        didSet {
            updateAppearance()
        }
    }
    
    var inactiveCountColor: UIColor = .tbxLightBlueGrey {
        didSet {
            updateAppearance()
        }
    }
    
    var buttonsWidth: CGFloat = 28 {
        didSet {
            incrementButton.touchMargin = buttonsWidth
            incWidthConstraint.constant = buttonsWidth
            decWidthConstraint.constant = buttonsWidth
            layoutIfNeeded()
        }
    }
    
    var buttonsHeight: CGFloat = 28 {
        didSet {
            decrementButton.touchMargin = buttonsWidth
            incHeightConstraint.constant = buttonsHeight
            decHeightConstraint.constant = buttonsHeight
            layoutIfNeeded()
        }
    }
    
    var labelMinimumWidth: CGFloat = 28 {
        didSet {
            countLblWidthConstraint.constant = labelMinimumWidth
            layoutIfNeeded()
        }
    }

    var labelHeight: CGFloat = 28 {
        didSet {
            countLblHeightConstraint.constant = labelHeight
            layoutIfNeeded()
        }
    }
    
    var minimumValue: Int = 1 {
        didSet {
            updateAppearance()
        }
    }
    
    var maximumValue: Int = .max {
        didSet {
            updateAppearance()
        }
    }
    
    var count: Int = 0 {
        didSet {
            countLabel.text = String(count)
            updateAppearance()
        }
    }
    
    var isEnabled: Bool = true {
        didSet {
            updateAppearance()
        }
    }
    
    func onDidChange(_ clossure: @escaping ActionHandler) {
        actionHandler = clossure
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        prepare()
    }
    
    override func layoutSubviews() {
        countLabel.xt.round()
    }
    
    func prepare() {
        
        isOpaque = true
        
        addSubview(stackView)
        
        incrementButton.touchMargin = buttonsWidth
        decrementButton.touchMargin = buttonsWidth
        
        incrementButton.xt.layout {
            incWidthConstraint = $0.width(buttonsWidth)
            incHeightConstraint = $0.height(buttonsHeight)
        }
        
        decrementButton.xt.layout {
            decWidthConstraint = $0.width(buttonsWidth)
            decHeightConstraint = $0.height(buttonsHeight)
        }
        
        stackView.xt.pinEdges()
        
        countLabel.xt.layout {
            countLblWidthConstraint = $0.width(labelMinimumWidth)
            countLblHeightConstraint = $0.height(labelHeight)
        }
        
        xt.layout {
            $0.height(.equal, to: stackView)
            $0.width(.equal, to: stackView)
        }
        
        count = minimumValue
        
        layoutIfNeeded()
    }
    
    private func updateAppearance() {
        incrementButton.tintColor = count < maximumValue ? activeStateColor : inactiveStateColor
        decrementButton.tintColor = count > minimumValue ? activeStateColor : inactiveStateColor
        incrementButton.isEnabled = count < maximumValue && isEnabled
        decrementButton.isEnabled = count > minimumValue && isEnabled
        countLabel.textColor = count > 0 ? activeCountColor : inactiveCountColor
        countLblWidthConstraint.constant = max(labelMinimumWidth,
                                               countLabel.intrinsicContentSize.width)
        countLabel.xt.round()
    }
    
    @objc private func incrementAction() {
        guard count < maximumValue else { return }
        count += 1
        actionHandler?(count, .increment)
    }
    
    @objc private func decrementAction() {
        guard count > minimumValue else { return }
        count -= 1
        actionHandler?(count, .decrement)
    }
}
