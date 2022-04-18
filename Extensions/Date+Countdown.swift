//
//  Date+Countdown.swift
//
//  Created by Sergey Gorin on 13/08/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import Foundation

extension Date {
        
    var timerString: String? {
        
        let currentDate = Date()
        let formatter = DateComponentsFormatter()
        
        if timeIntervalSince(currentDate) < 86400 {
            formatter.unitsStyle = .abbreviated
            formatter.zeroFormattingBehavior = [.pad]
            formatter.includesTimeRemainingPhrase = false
            
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.hour, .minute, .second], from: currentDate, to: self)
            
            let hours = dateComponents.hour ?? 0
            let minutes = dateComponents.minute ?? 0
            let seconds = dateComponents.second ?? 0
            
            formatter.allowedUnits = [.hour]
            
            let hourSymbol = formatter
                .string(from: dateComponents)?
                .components(separatedBy: CharacterSet.letters.inverted)
                .joined()
                .prefix(1) ?? ""
            
            formatter.allowedUnits = [.minute]
            
            let minuteSymbol = formatter
                .string(from: dateComponents)?
                .components(separatedBy: CharacterSet.letters.inverted)
                .joined()
                .prefix(1) ?? ""
            
            formatter.allowedUnits = [.second]
            
            let secondSymbol = formatter
                .string(from: dateComponents)?
                .components(separatedBy: CharacterSet.letters.inverted)
                .joined()
                .prefix(1) ?? ""
            
            return "\(hours) \(hourSymbol) : \(minutes) \(minuteSymbol) : \(seconds) \(secondSymbol)"
            
        } else {
            formatter.unitsStyle = .full
            formatter.allowedUnits = [.day]
            formatter.includesTimeRemainingPhrase = true
        }
        
        return formatter.string(from: currentDate, to: self)
    }
}
