//
//  PlaceholderTextView.swift
//
//  Created by Sergey Gorin on 04/05/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

class PlaceholderTextView: UITextView {
    
    private var accesoryInputNext: ((_ textView: UITextView) -> ())?
    private var accesoryInputPrevious: ((_ textView: UITextView) -> ())?
    
    @IBInspectable var placeholder: String {
        get {
            return placeholderLabel.text ?? ""
        }
        set {
            placeholderLabel.text = newValue
        }
    }
    
    @IBInspectable var placeholderColor: UIColor {
        get {
            return placeholderLabel.textColor
        }
        set {
            placeholderLabel.textColor = newValue
        }
    }
    
    var placeholderOffset: CGPoint = .zero {
        didSet {
            leadingLabelConstr.constant = placeholderOffset.x
            topLabelConstr.constant = placeholderOffset.y
            widthLabelConstr.constant = -(placeholderOffset.x * 2)
        }
    }
    
    var placeholderFont: UIFont {
        get {
            return placeholderLabel.font
        }
        set {
            placeholderLabel.font = newValue
            layoutIfNeeded()
        }
    }
    
    var attributedPlaceholder: NSAttributedString! {
        get {
            return placeholderLabel.attributedText
        }
        set {
            placeholderLabel.attributedText = newValue
        }
    }
    
    enum InputAccessoryView {
        case none
        case `default`
        case custom(UIView)
    }
    
    var inputAccessory: InputAccessoryView = .none {
        didSet {
            switch inputAccessory {
            case .none: break
            case .default: inputAccessoryView = inputToolbar
            case .custom(let view): inputAccessoryView = view
            }
        }
    }
    
    lazy var inputToolbar: UIToolbar = {
        return UIToolbar().with {
            $0.barStyle = .black
            $0.isTranslucent = true
            $0.sizeToFit()
            $0.tintColor = .white
            
            let doneButton = UIBarButtonItem(title: L10n.done,
                                             style: .plain,
                                             target: self,
                                             action: #selector(done))
            let flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                                      target: nil, action: nil)
            let fixedSpaceButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace,
                                                   target: nil, action: nil)
            
            let nextButton = UIBarButtonItem(image: Asset.InputToolbar.next.image,
                                             style: .plain,
                                             target: self,
                                             action: #selector(nextField))
            nextButton.width = 50.0
            let previousButton = UIBarButtonItem(image: Asset.InputToolbar.previous.image,
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(previousField))
            
            $0.setItems([fixedSpaceButton, previousButton, fixedSpaceButton,
                         nextButton, flexibleSpaceButton, doneButton], animated: false)
            $0.isUserInteractionEnabled = true
            $0.xt.onPan { [unowned self] r in
                let tr  = r.translation(in: r.view)
                if tr.y > 0 {
                    if self.isFirstResponder {
                        self.resignFirstResponder()
                    }
                }
            }
        }
    }()
    
    override var text: String! {
        didSet {
            textDidChange()
        }
    }
    
    override var attributedText: NSAttributedString! {
        didSet {
            textDidChange()
            layoutIfNeeded()
        }
    }
    
    override var bounds: CGRect {
        didSet {
            layoutIfNeeded()
        }
    }
    
    override var frame: CGRect {
        didSet {
            layoutIfNeeded()
        }
    }
    
    override var font: UIFont? {
        didSet {
            layoutIfNeeded()
        }
    }
    
    override var textAlignment: NSTextAlignment {
        didSet {
            placeholderLabel.textAlignment = textAlignment
            layoutIfNeeded()
        }
    }
    
    override var textContainerInset: UIEdgeInsets {
        didSet {
            NSLayoutConstraint.deactivate(placeholderConstraints)
            addConstraints(placeholderConstraints)
            layoutIfNeeded()
        }
    }
    
    private var notificationCenter = NotificationCenter.default
    private lazy var placeholderLabel: UILabel = {
        let pLabel = UILabel()
        pLabel.backgroundColor = .clear
        pLabel.textColor = {
            let textField = UITextField()
            textField.attributedPlaceholder = NSAttributedString(string: ".")
            return textField.value(forKeyPath: "placeholderLabel.textColor") as? UIColor
                ?? UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
        }()
        pLabel.numberOfLines = 0
        pLabel.isUserInteractionEnabled = false
        pLabel.font = self.font
        pLabel.textAlignment = self.textAlignment
        pLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return pLabel
    }()
    
    private var leadingLabelConstr: NSLayoutConstraint!
    private var topLabelConstr: NSLayoutConstraint!
    private var widthLabelConstr: NSLayoutConstraint!
    private var placeholderConstraints: [NSLayoutConstraint] {
        leadingLabelConstr = NSLayoutConstraint(
            item: self.placeholderLabel,
            attribute: .left,
            relatedBy: .equal,
            toItem: self,
            attribute: .left,
            multiplier: 1.0,
            constant: placeholderOffset.x
        )
        
        topLabelConstr = NSLayoutConstraint(
            item: self.placeholderLabel,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1.0,
            constant: placeholderOffset.y
        )
        widthLabelConstr = NSLayoutConstraint(
            item: self.placeholderLabel,
            attribute: .width,
            relatedBy: .equal,
            toItem: self,
            attribute: .width,
            multiplier: 1.0,
            constant: -(self.textContainerInset.left + self.textContainerInset.right + self.textContainer.lineFragmentPadding * 2.0)
        )
        return [leadingLabelConstr, topLabelConstr, widthLabelConstr]
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // To fix anecessary jumping
    override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        super.setContentOffset(contentOffset, animated: false)
    }
    
    fileprivate func setup() {
        addSubview(placeholderLabel)
        addConstraints(placeholderConstraints)
        
        placeholderOffset = CGPoint(x: textContainerInset.left + textContainer.lineFragmentPadding,
                                    y: textContainerInset.top)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(textDidChange),
                                       name: UITextView.textDidChangeNotification,
                                       object: nil)
    }
    
    deinit {
        notificationCenter.removeObserver(self, name: UITextView.textDidChangeNotification, object: self)
    }
    
    @objc private func textDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }
    
    @objc private func done() {
        let iv = inputView
        if iv == nil || iv?.xt.isScrolling == false {
            resignFirstResponder()
        }
    }
    
    @objc private func nextField() {
        accesoryInputNext?(self)
    }
    
    @objc private func previousField() {
        accesoryInputPrevious?(self)
    }
}

extension PlaceholderTextView {
    
    func onNextInput(_ handler: ((_ textView: UITextView) -> ())?) {
        accesoryInputNext = handler
    }
    
    func onPreviousInput(_ handler: ((_ textView: UITextView) -> ())?) {
        accesoryInputPrevious = handler
    }
}
