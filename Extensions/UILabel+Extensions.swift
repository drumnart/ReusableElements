//
//  UILabel+Extensions.swift
//
//  Created by Sergey Gorin on 30/04/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

extension UILabel {

    func setAttributedText(
        _ text: String,
        alignment: NSTextAlignment = .left,
        minLineHeight: CGFloat = 19,
        lineHeightMultiple: CGFloat = 1.0,
        lineSpacing: CGFloat = 0,
        kern: CGFloat = 0,
        font: UIFont = .regular(12),
        foregroundColor: UIColor = .black) {
        
        let paragraph = NSMutableParagraphStyle().with {
            $0.lineSpacing = lineSpacing
            $0.lineHeightMultiple = lineHeightMultiple
            $0.alignment = alignment
            $0.minimumLineHeight = minLineHeight
        }
        
        self.font = font
        
        let attrText = NSAttributedString(
            string: text,
            attributes: [
                .paragraphStyle: paragraph,
                .kern: kern,
                .font: font,
                .foregroundColor: foregroundColor,
            ]
        )
        attributedText = attrText
    }
    
    func renderHTML(_ htmlString: String,
                    encoding: String.Encoding = .utf16,
                    wrapsInBodyWithRedefinedImgSize: Bool = false,
                    inheritsFont: Bool = false,
                    trimmingCharactersIn charSet: CharacterSet? = nil) {
        
        var modifiedHtmlString = htmlString
        
        if let font = font, inheritsFont == true {
            modifiedHtmlString = String(format: "<span style=\"font-family: \(font.fontName); font-size: \(font.pointSize)\">%@</span>", arguments: [htmlString])
        }
        
        if wrapsInBodyWithRedefinedImgSize {
            modifiedHtmlString = "<head><style type=\"text/css\"> img{ max-height: 100%; max-width: \(frame.size.width) !important; width: auto; height: auto;} </style> </head><body> \(modifiedHtmlString) </body>"
        }
        
        if let data = modifiedHtmlString.data(using: encoding),
            let at = try? NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html],
                documentAttributes: nil) {
            
            if let charSet = charSet {
                attributedText = at.trimmingCharacters(in: charSet)
            } else {
                attributedText = at
            }
        } else {
            if let charSet = charSet {
                text = htmlString.trimmingCharacters(in: charSet)
            } else {
                text = htmlString
            }
        }
    }
}
