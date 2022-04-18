//
//  Foundation+Extensions.swift
//
//  Created by Sergey Gorin on 04/02/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import Foundation

extension Array {
    subscript (safe index: Int) -> Element? {
        return index >= 0 && index < count ? self[index] : nil
    }
    
    mutating func replace(at index: Int, with newElement: Element) {
        remove(at: index)
        insert(newElement, at: index)
    }
}

extension Array where Element : Equatable {
    
    /// Remove first matched object
    
    mutating func remove(_ object : Element) {
        if let index = firstIndex(of: object) {
            self.remove(at: index)
        }
    }
}

extension Array where Element: Hashable {
    
    // Remove duplicates
    func distinct() -> [Element] {
        var seen = Set<Element>(minimumCapacity: count)
        return filter {
            let unseen = !seen.contains($0)
            seen.insert($0)
            return unseen
        }
    }
    
    static func distinct<S: Sequence, E: Hashable>(_ source: S) -> [E] where E==S.Iterator.Element {
        var seen: [E: Bool] = [:]
        return source.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}

extension DateFormatter {
    
    static let utcDefaultDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    
    static var utc: DateFormatter {
        return DateFormatter.utcDateFormatter
    }
    
    static var iso8601: DateFormatter {
        return DateFormatter.iso8601DateFormatter
    }
    
    private static let utcDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
    
    private static let iso8601DateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}

extension Date {
    
    var nextDay: Date? {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)
    }
    
    public var timestamp: Int64 { return Int64(timeIntervalSince1970 * 1000) }
    
    public var utcString: String { return DateFormatter.utc.string(from: self) }
    
    init(utcString: String, format: String = DateFormatter.utcDefaultDateFormat) {
        let formatter = DateFormatter.utc
        formatter.dateFormat = format
        self = formatter.date(from: utcString) ?? Date(timeIntervalSinceReferenceDate: 0)
    }
    
    public func toString(dateStyle dstyle: DateFormatter.Style = .medium,
                         timeStyle tstyle: DateFormatter.Style = .none,
                         dateFormat: String? = nil,
                         localized: Bool = true) -> String {
        let formatter = DateFormatter.utc
        if localized {
            formatter.locale = Locale.current
            formatter.timeZone = Locale.current.calendar.timeZone
        }
        formatter.dateStyle = dstyle
        formatter.timeStyle = tstyle
        
        if let format = dateFormat {
            if localized {
                formatter.setLocalizedDateFormatFromTemplate(format)
            } else {
                formatter.dateFormat = format
            }
        }
        
        return formatter.string(from: self)
    }
    
    func converted(fromTimeZone: TimeZone, to newTimeZone: TimeZone) -> Date {
        let delta = TimeInterval(-fromTimeZone.secondsFromGMT() + newTimeZone.secondsFromGMT())
        return addingTimeInterval(delta)
    }
    
    func timeRemainingFormatted(
        unitsStyle: DateComponentsFormatter.UnitsStyle = .positional,
        allowedUnits: NSCalendar.Unit = [.hour, .minute, .second],
        zeroFormattingBehavior: DateComponentsFormatter.ZeroFormattingBehavior = [.pad]
    ) -> String? {
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = unitsStyle
        formatter.allowedUnits = allowedUnits
        formatter.zeroFormattingBehavior = zeroFormattingBehavior
        
        return formatter.string(from: Date(), to: self)
    }
}

extension Date {
    
    func isBetween(start: Inclusivity<Date>, end: Inclusivity<Date>) -> Bool {
        switch (start, end) {
        case let (.including(first), .including(second)):
            return self >= first && self <= second
            
        case let (.including(first), .excluding(second)):
            return self >= first && self < second
            
        case let (.excluding(first), .including(second)):
            return self > first && self <= second
            
        case let (.excluding(first), .excluding(second)):
            return self > first && self < second
        }
    }
}

extension TimeZone {
    
    static let zero = TimeZone(secondsFromGMT: 0) ?? .current
}

extension TimeInterval {
    
    func timeRemainingFormatted(
        unitsStyle: DateComponentsFormatter.UnitsStyle = .positional,
        allowedUnits: NSCalendar.Unit = [.day, .hour, .minute, .second],
        zeroFormattingBehavior: DateComponentsFormatter.ZeroFormattingBehavior = [.pad]
    ) -> String {
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = unitsStyle
        formatter.allowedUnits = allowedUnits
        formatter.zeroFormattingBehavior = zeroFormattingBehavior
        
        return formatter.string(from: self) ?? ""
    }
}

extension Dictionary {
    public func get<T>(_ key: Key) -> T? {
        return self[key] as? T
    }
    
    public func get<T>(_ key: Key, `else` `default`: T) -> T {
        return self[key] as? T ?? `default`
    }

    subscript <T>(_ key: Key, `else` `default`: T) -> T {
        return get(key, else: `default`)
    }
    
    public func get(_ key: Key) -> Int {
        return self[key] as? Int ?? Int()
    }
    
    public func get(_ key: Key) -> Double {
        return self[key] as? Double ?? Double()
    }
    
    public func get(_ key: Key) -> Float {
        return self[key] as? Float ?? Float()
    }
    
    public func get(_ key: Key) -> NSNumber {
        return self[key] as? NSNumber ?? NSNumber()
    }
    
    public func get(_ key: Key) -> String {
        return self[key] as? String ?? String()
    }
    
    public func get(_ key: Key) -> Bool {
        return self[key] as? Bool ?? Bool()
    }
    
    public func get(_ key: Key) -> Array<Any> {
        return self[key] as? [Any] ?? []
    }
    
    public func get(_ key: Key) -> Dictionary<Key, Any> {
        return self[key] as? [Key: Any] ?? [:]
    }
    
    public func get(_ key: Key) -> NSNull {
        return self[key] as? NSNull ?? NSNull()
    }
    
    public func merge(with other: Dictionary) -> Dictionary {
        return merge(self, other)
    }
    
    public static func + (lhs: [Key: Value], rhs: [Key: Value]) -> Dictionary {
        return lhs.merge(with: rhs)
    }
}

extension ExpressibleByDictionaryLiteral where Key : Hashable {
    func merge<K, V>(_ left: [K: V], _ right: [K: V]) -> [K: V] {
        return left.reduce(right) {
            var new = $0 as [K: V]
            new.updateValue($1.1, forKey: $1.0)
            return new
        }
    }
}

extension DispatchQueue {
    
    static var currentLabel: String? {
        return String(validatingUTF8: __dispatch_queue_get_label(nil))
    }
    
    static func main(_ closure: @escaping () -> Void) {
        if self === DispatchQueue.main && Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async {
                closure()
            }
        }
    }
    
    static func delay(_ delay: TimeInterval, in queue: DispatchQueue = .main, closure: @escaping () -> Void) {
        queue.asyncAfter(deadline: DispatchTime.now() + delay, execute: closure)
    }
}

func delay(_ delay: TimeInterval, in queue: DispatchQueue = .main, closure: @escaping () -> Void) {
    DispatchQueue.delay(delay, in: queue, closure: closure)
}

extension NotificationCenter {
    
    func addUniqueObserver(_ observer: AnyObject,
                           selector: Selector,
                           name: NSNotification.Name?,
                           object: AnyObject?) {
        removeObserver(observer, name: name, object: object)
        addObserver(observer, selector: selector, name: name, object: object)
    }
    
    func addOneTimeObserver(forName name: NSNotification.Name?,
                            object: Any?,
                            queue: OperationQueue? = .main) {
        var token: NSObjectProtocol?
        token = addObserver(forName: name, object: object, queue: queue) { [unowned self] _ in
            token.let{ self.removeObserver($0) }
        }
    }
}

extension Notification.Name {
    func post(object: Any? = nil, userInfo: [AnyHashable: Any]? = nil) {
        NotificationCenter.default.post(name: self, object: object, userInfo: userInfo)
    }
}

extension String {
    
    static let empty = ""
    
    static let space = " "
    
    /// Length of the string
    var length: Int {
        return count
    }
    
    /// Empty or only whitespace and newline characters
    var isBlank: Bool {
        return trimmed().isEmpty
    }
    
    /// Returns a new trimmed string
    func trimmed(in characterSet: CharacterSet = .whitespacesAndNewlines) -> String {
        return trimmingCharacters(in: characterSet)
    }
    
    /// Check if self is email
    var isEmail: Bool {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let firstMatch = detector?.firstMatch(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, length))
        
        return (firstMatch?.range.location != NSNotFound && firstMatch?.url?.scheme == "mailto")
    }
    
    /// Check if self is Phone Number
    var isPhoneNumber: Bool {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
        let firstMatch = detector?.firstMatch(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, length))
        return (firstMatch?.range.location != NSNotFound && firstMatch?.resultType == NSTextCheckingResult.CheckingType.phoneNumber)
    }
    
    var digitsOnly: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
    
    func deletingPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }
    
    func matches(regex: String) -> Bool {
        return range(of: regex, options: .regularExpression) != nil
    }
    
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in String(self[substringFrom..<substringTo])
            }
        }
    }
}

extension NSAttributedString {
    
    public func trimmingCharacters(in characterSet: CharacterSet) -> NSAttributedString {
        let modifiedString = NSMutableAttributedString(attributedString: self)
        modifiedString.trimCharacters(in: characterSet)
        return NSAttributedString(attributedString: modifiedString)
    }
    
    func withHiglightedOccurances(
        of searchString: String,
        highlightAttributes: [NSAttributedString.Key: Any]
    ) -> NSAttributedString? {
        
        let attributedString = NSMutableAttributedString(attributedString: self)

        do {
            let regex = try NSRegularExpression(
                pattern: searchString,
                options: .caseInsensitive
            )
            let range = NSRange(location: 0, length: string.utf16.count)
            regex
                .matches(in: string, options: .withTransparentBounds, range: range)
                .forEach {
                    attributedString.addAttributes(
                        highlightAttributes,
                        range: $0.range
                    )
            }
            return attributedString
            
        } catch {
            print("[ERROR] \(error)")
            return nil
        }
    }
}

extension NSMutableAttributedString {
    public func trimCharacters(in characterSet: CharacterSet) {
        var range = (string as NSString).rangeOfCharacter(from: characterSet)
        
        // Trim leading characters from character set.
        while range.length != 0 && range.location == 0 {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: characterSet)
        }
        
        // Trim trailing characters from character set.
        range = (string as NSString).rangeOfCharacter(from: characterSet, options: .backwards)
        while range.length != 0 && NSMaxRange(range) == length {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: characterSet, options: .backwards)
        }
    }
}

extension Int {
    var boolValue: Bool { self != 0 }
}

extension Bool {
    var intValue: Int { self ? 1 : 0 }
}

extension Locale {
    
    static func getCurrencySymbol(for currencyCode: String) -> String? {
        guard currencyCode.isBlank == false else { return nil }
        
        if let currencySymbol = NSLocale(localeIdentifier: currencyCode)
            .displayName(forKey: .currencySymbol, value: currencyCode), currencySymbol.count < 3 {
            return currencySymbol
        }
        
        let currencySymbol = Locale.availableIdentifiers
            .map { Locale(identifier: $0) }
            .first { $0.currencyCode == currencyCode }?
            .currencySymbol

        return currencySymbol
    }
}
