//
//  UITextView+Extensions.swift
//
//  Created by Sergey Gorin on 30/04/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

extension UITextView {
    
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
                options: [.documentType : NSAttributedString.DocumentType.html],
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
