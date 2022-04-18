//
//  UIFont+Extensions.swift
//
//  Created by Sergey Gorin on 25/02/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

extension UIFont {
    
    static func thin(_ size: CGFloat) -> UIFont {
        return .systemFont(ofSize: size, weight: .thin)
    }
    
    static func light(_ size: CGFloat) -> UIFont {
        return .systemFont(ofSize: size, weight: .light)
    }
    
    static func regular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-Regular", size: size)
            ?? .systemFont(ofSize: size, weight: .regular)
    }
    
    static func medium(_ size: CGFloat) -> UIFont {
        return .systemFont(ofSize: size, weight: .medium)
    }
    
    static func semibold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-SemiBold", size: size)
            ?? .systemFont(ofSize: size, weight: .semibold)
    }
    
    static func bold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-Bold", size: size)
            ?? .systemFont(ofSize: size, weight: .bold)
    }
}

extension UIFont {
    
    static func printFontNames() {
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) Font names: \(names)")
        }
    }
    
    func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits) ?? fontDescriptor
        return UIFont(descriptor: descriptor, size: 0)
    }
    
    var bold: UIFont {
        return withTraits(traits: .traitBold)
    }
    
    var italic: UIFont {
        return withTraits(traits: .traitItalic)
    }
}
