//
//  FormFieldComponent.swift
//
//  Created by Sergey Gorin on 18/04/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

extension FormFieldComponent {
    func onTextFieldShouldBeginEditing(_ handler: TextFieldShouldBeginEditing?) {
        textFieldShouldBeginEditingHandler = handler
    }
    
    func onTextFieldDidBeginEditing(_ handler: TextFieldDidBeginEditing?) {
        textFieldDidBeginEditing = handler
    }
    
    func onTextFieldShouldChangeCharactersInRange(_ handler: TextFieldShouldChangeCharactersInRange?) {
        textFieldShouldChangeCharactersInRangeHandler = handler
    }
    
    func onTextFieldEditingDidChange(_ handler: TextFieldEditingDidChange?) {
        textFieldEditingDidChange = handler
    }
    
    func onTextFieldShouldReturn(_ handler: TextFieldShouldBeginEditing?) {
        textFieldShouldReturnHandler = handler
    }
    
    func onTextFieldDidEndEditing(_ handler: TextFieldDidEndEditing?) {
        textFieldDidEndEditing = handler
    }
    
    func onNextInput(_ handler: ((_ textField: UITextField) -> ())?) {
        accesoryInputNext = handler
    }
    
    func onPreviousInput(_ handler: ((_ textField: UITextField) -> ())?) {
        accesoryInputPrevious = handler
    }
}

/// Label and TextField

class FormFieldComponent: UIView {
    
    typealias TextFieldShouldBeginEditing = (_ textField: UITextField) -> Bool
    typealias TextFieldDidBeginEditing = (_ textField: UITextField) -> ()
    typealias TextFieldShouldChangeCharactersInRange = (
        _ textField: UITextField,
        _ range: NSRange,
        _ replacementString: String) -> Bool
    typealias TextFieldEditingDidChange  = (_ textField: UITextField) -> ()
    typealias TextFieldShouldReturn = (_ textField: UITextField) -> Bool
    typealias TextFieldDidEndEditing = (_ textField: UITextField) -> ()
    
    private var textFieldShouldBeginEditingHandler: TextFieldShouldBeginEditing?
    private var textFieldDidBeginEditing: TextFieldDidBeginEditing?
    private var textFieldShouldChangeCharactersInRangeHandler: TextFieldShouldChangeCharactersInRange?
    private var textFieldEditingDidChange: TextFieldEditingDidChange?
    private var textFieldShouldReturnHandler: TextFieldShouldReturn?
    private var textFieldDidEndEditing: TextFieldDidEndEditing?
    private var accesoryInputNext: ((_ textField: UITextField) -> ())?
    private var accesoryInputPrevious: ((_ textField: UITextField) -> ())?
    
    private var titleHeightConstr: NSLayoutConstraint!
    private var textFieldHeightConstr: NSLayoutConstraint!
    private var textFieldLeadingConstr: NSLayoutConstraint!
    private var spacingConstr: NSLayoutConstraint!
    
    var titleLabel: UILabel!
    var requiredSignImageView: UIImageView!
    var borderedView: UIView!
    var textField: UITextFieldPadding!
    var accessoryView: UIImageView!
    
    var text: String? {
        get {
            return textField?.text
        }
        set {
            textField?.text = newValue
            update()
        }
    }
    
    var textFont: UIFont = .light(17) {
        didSet {
            textField?.font = textFont
            update()
        }
    }
    
    var textColor: UIColor = .black {
        didSet {
            update()
        }
    }
    
    var title: String? {
        didSet {
            update()
        }
    }
    
    var titleColor: UIColor = .black {
        didSet {
            updateTitleLabel()
        }
    }
    
    var titleFont: UIFont = .light(12) {
        didSet {
            updateTitleLabel()
        }
    }
    
    var editModeTitleColor: UIColor = .black {
        didSet {
            updateTitleLabel()
        }
    }
    
    var isRequiredField: Bool = false {
        didSet {
            updateRequiredSignImageView()
        }
    }
    
    var isEnabled: Bool = true {
        didSet {
            textField.isEnabled = isEnabled
            updatePlaceholder()
        }
    }
    
    var placeholder: String? {
        didSet {
            updatePlaceholder()
        }
    }
    
    var placeholderColor: UIColor = .tbxSecondaryText {
        didSet {
            updatePlaceholder()
        }
    }
    
    var placeHolderFont: UIFont = .regular(12) {
        didSet {
            updatePlaceholder()
        }
    }
    
    var errorMessage: String? {
        didSet {
            update()
        }
    }
    
    var errorColor: UIColor = .tbxSalmonPink
    
    var disabledColor: UIColor = UIColor(white: 0.7, alpha: 1.0) {
        didSet {
            updateTitleLabel()
            updatePlaceholder()
        }
    }
    
    /// Determines whether the receiver has an error message.
    var hasErrorMessage: Bool {
        return errorMessage?.isBlank == false
    }
    
    var titleLabelHeight: CGFloat = 24.0 {
        didSet {
            titleHeightConstr.constant = titleLabelHeight
            layoutIfNeeded()
        }
    }
    
    var textFieldHeight: CGFloat = 40 {
        didSet {
            textFieldHeightConstr.constant = textFieldHeight
            layoutIfNeeded()
        }
    }
    
    /// Spacing between label and textField
    var spacing: CGFloat = 5.0 {
        didSet {
            spacingConstr.constant = spacing
            layoutIfNeeded()
        }
    }
    
    /// Spacing between borderedView leading edge and textField
    var textFieldIntent: CGFloat = 20.0 {
        didSet {
            textFieldLeadingConstr.constant = textFieldIntent
            layoutIfNeeded()
        }
    }
    
    struct TitleAnimationOptions {
        var fadeInDuration: TimeInterval = 0.2
        var fadeOutDuration: TimeInterval = 0.25
    }
    var titleAnimationOptions = TitleAnimationOptions()
    
    enum TitleVisibilityMode {
        case `default`          // Always visible
        case onlyOnEditing      // Visible only when editing is true or has error
    }
    var titleVisibilityMode: TitleVisibilityMode = .default
    
    var attributedTitleFormatter: ((NSAttributedString, _ isError: Bool) -> NSAttributedString)?
    
    var titleFormatter: (String) -> String = {
        return $0
    }
    
    enum TextFieldInputAccessoryView {
        case none
        case `default`
        case custom(UIView)
    }
    
    var textfieldInputAccessory: TextFieldInputAccessoryView = .default
    
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
            
            let nextButton = UIBarButtonItem(image: inputToolBarNextBtnImage,
                                             style: .plain,
                                             target: self,
                                             action: #selector(nextField))
            nextButton.width = 50.0
            let previousButton = UIBarButtonItem(image: inputToolBarPreviousBtnImage,
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(previousField))
            
            $0.setItems([fixedSpaceButton, previousButton, fixedSpaceButton,
                         nextButton, flexibleSpaceButton, doneButton], animated: false)
            $0.isUserInteractionEnabled = true
            $0.xt.onPan { [unowned self] r in
                let tr  = r.translation(in: r.view)
                if tr.y > 0 {
                    if self.textField.isFirstResponder {
                        self.textField.resignFirstResponder()
                    }
                }
            }
        }
    }()
    
    var inputToolBarNextBtnImage: UIImage! = Asset.InputToolbar.next.image
    var inputToolBarPreviousBtnImage: UIImage! = Asset.InputToolbar.previous.image
    
    var isTitleVisible: Bool {
        textField.hasText || hasErrorMessage
    }
    
    func update(animated: Bool = false) {
        updateTextColor()
        updateTitleLabel(animated: animated)
        updatePlaceholder()
        updateRequiredSignImageView()
    }
    
    private func updatePlaceholder() {
        let color = textField.isEnabled ? placeholderColor : disabledColor
        textField?.attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "",
            attributes: [
                NSAttributedString.Key.foregroundColor: color,
                NSAttributedString.Key.font: placeHolderFont
            ]
        )
    }
    
    fileprivate func updateTextColor() {
        if !isEnabled {
            textField.textColor = disabledColor
        } else if hasErrorMessage {
            textField.textColor = errorColor
        } else {
            textField.textColor = textColor
        }
    }
    
    fileprivate func updateTitleLabel(animated: Bool = false) {
        
        if let attrFormatter = attributedTitleFormatter {
            titleLabel.attributedText = hasErrorMessage
                ? attrFormatter(
                    NSAttributedString(
                        string: errorMessage?.uppercased() ?? "",
                        attributes: [
                            NSAttributedString.Key.foregroundColor: errorColor,
                            NSAttributedString.Key.font: titleFont
                        ]
                    ),
                    hasErrorMessage)
                    
                : attrFormatter(
                    NSAttributedString(
                        string: title ?? "",
                        attributes: [
                            NSAttributedString.Key.foregroundColor: titleColor,
                            NSAttributedString.Key.font: titleFont
                        ]
                    ),
                    hasErrorMessage)
        } else {
            titleLabel.text = hasErrorMessage
                ? titleFormatter(errorMessage?.uppercased() ?? "")
                : titleFormatter(title ?? "")
            titleLabel.textColor = hasErrorMessage ? errorColor : titleColor
            titleLabel.font = titleFont
        }
        
        updateTitleVisibility(animated: animated)
    }
    
    private func updateTitleVisibility(animated: Bool = false, completion: ((Bool) -> Void)? = nil) {
        
        guard titleVisibilityMode == .onlyOnEditing else { return }
        
        let change = {
            self.titleLabel.alpha = self.isTitleVisible ? 1.0 : 0.0
        }
        
        if animated {
            let duration = self.isTitleVisible
                ? titleAnimationOptions.fadeInDuration
                : titleAnimationOptions.fadeOutDuration
            
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: .curveEaseOut,
                animations: change,
                completion: completion
            )
        } else {
            change()
            completion?(true)
        }
    }
    
    func updateRequiredSignImageView() {
        requiredSignImageView.isHidden = !isRequiredField || hasErrorMessage
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textField?.frame.size.height = self.textFieldHeight
    }
    
    func prepareForReuse() {
        textField?.text = ""
        textField?.placeholder = ""
        errorMessage = nil
        accessoryView?.isHidden = true
        invalidateIntrinsicContentSize()
    }
    
    func configure() {
        configureView()
        activateConstraints()
        addObservers()
    }
    
    func addObservers() {
        textField?.addTarget(self, action: #selector(editingChanged),
                             for: .editingChanged)
    }
    
    func configureView() {
        
        titleLabel = UILabel().with {
            $0.textColor = .black
            $0.font = titleFont
            addSubview($0)
        }
        
        requiredSignImageView = UIImageView().with {
            $0.isHidden = isRequiredField
            addSubview($0)
        }
        
        textField = UITextFieldPadding().with {
            $0.delegate = self
            $0.autocorrectionType = .no
            $0.autocapitalizationType = .none
            $0.font = textFont
            $0.allowsEditingTextAttributes = false
            
            addSubview($0)
        }
        
        borderedView = UIView().with {
            $0.xt.round(borderWidth: 1.0,
                        borderColor: .tbxBrownGreyTwo,
                        cornerRadius: 4.0)
            $0.xt.rasterize()
            $0.addSubview(textField)
            addSubview($0)
        }
        
        accessoryView = UIImageView().with {
            $0.isHidden = true
            addSubview($0)
        }
        
        update()
    }
    
    func activateConstraints() {
        
        titleHeightConstr = titleLabel.heightAnchor
            .constraint(equalToConstant: titleLabelHeight).xt.activate()
        
        textFieldHeightConstr = textField.heightAnchor
            .constraint(equalToConstant: textFieldHeight).xt.activate()
        
        spacingConstr = borderedView.topAnchor
            .constraint(equalTo: titleLabel.bottomAnchor,
                        constant: spacing).xt.activate()
        
        textFieldLeadingConstr = textField.leadingAnchor.constraint(
            equalTo: leadingAnchor,
            constant: textFieldIntent
        ).xt.activate()
        
        NSLayoutConstraint.xt.activate(
            [
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                titleLabel.topAnchor.constraint(equalTo: topAnchor),
                
                requiredSignImageView.leadingAnchor.constraint(
                    equalTo: titleLabel.trailingAnchor,
                    constant: 5.0
                ),
                requiredSignImageView.centerYAnchor.constraint(
                    equalTo: titleLabel.centerYAnchor,
                    constant: 2.0
                ),
                requiredSignImageView.widthAnchor.constraint(equalToConstant: 6),
                requiredSignImageView.heightAnchor.constraint(equalToConstant: 6),
                
                borderedView.leadingAnchor.constraint(equalTo: leadingAnchor),
                borderedView.trailingAnchor.constraint(equalTo: trailingAnchor),
                borderedView.bottomAnchor.constraint(equalTo: bottomAnchor),
                
                textField.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                    constant: -10.0),
                textField.topAnchor.constraint(equalTo: borderedView.topAnchor),
                textField.bottomAnchor.constraint(equalTo: borderedView.bottomAnchor),
                
                accessoryView.trailingAnchor.constraint(equalTo: borderedView.trailingAnchor,
                                                        constant: -20.0),
                accessoryView.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
                accessoryView.heightAnchor.constraint(equalToConstant: 14),
                accessoryView.widthAnchor.constraint(equalToConstant: 14)
            ]
        )
    }
    
    @objc private func editingChanged(_ textField: UITextField) {
        update(animated: true)
        textFieldEditingDidChange?(textField)
    }
    
    @objc private func done() {
        let iv = textField.inputView
        if iv == nil || iv?.xt.isScrolling == false {
            textField.resignFirstResponder()
        }
    }
    
    @objc private func nextField() {
        accesoryInputNext?(textField)
    }
    
    @objc private func previousField() {
        accesoryInputPrevious?(textField)
    }
}

extension FormFieldComponent: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textfieldInputAccessory {
        case .none: break
        case .default: textField.inputAccessoryView = inputToolbar
        case .custom(let view): textField.inputAccessoryView = view
        }
        
        return textFieldShouldBeginEditingHandler?(textField) ?? true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldDidBeginEditing?(textField)
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return textFieldShouldChangeCharactersInRangeHandler?(textField, range, string) ?? true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textFieldShouldReturnHandler?(textField) ?? false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.setNeedsLayout()
        textField.layoutIfNeeded()
        textFieldDidEndEditing?(textField)
    }
}

class UITextFieldPadding: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
  
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
