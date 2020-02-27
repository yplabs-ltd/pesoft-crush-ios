//
//  NSDate+Extension.swift
//  DateApp
//
//  Created by ryan on 2/13/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import Foundation

private let dateStringFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM. dd"
    return formatter
}()

private let fullDateStringFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy. MM. dd"
    return formatter
}()

extension Date {
    // 현재 기준으로 만기되었는가 확인
    func expired() -> Bool {
        let expiredDttm = self
        let interval = NSDate().timeIntervalSince(expiredDttm)
        if interval < 0 {
            // expiredDttm 이 미래 (아직 expired 되지 않음)
            return false
        }
        return true
    }
    
    func later(_ otherDate: Date) -> Date {
        switch self.compare(otherDate) {
        case .orderedAscending:
            return otherDate
        default:
            return self
        }
    }
    
    public func timeAgoForComment() -> String {
        let now: Date = Date()
        
        let deltaSeconds = fabs(self.timeIntervalSinceNow)
        let deltaMinutes = deltaSeconds / 60.0
        let deltaHours = deltaMinutes / 60.0
        
        if deltaSeconds < 60 {
            return NSLocalizedString("방금전", comment: "")
        }
        
        if deltaMinutes < 60 {
            return NSLocalizedString("\(Int(deltaMinutes))분전", comment: "")
        }
        
        let timeTruncatedToday: Date = now.timeTruncatedDate() ?? now

        if self.later(timeTruncatedToday) == self {
            return String.localizedStringWithFormat(NSLocalizedString("%d시간 전", comment: ""), Int(deltaHours))
        }
        if deltaHours < 240 {
            return String.localizedStringWithFormat(NSLocalizedString("%d일 전", comment: ""), Int(deltaHours/24.0)+1)
        }
        if self.getYear() == now.getYear() {
            return dateStringFormatter.string(from: self)
        }
        
        return fullDateStringFormatter.string(from: self)
    }
    
    
    public func getYear() -> Int {
        let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        let components = gregorian.dateComponents([.year], from: self)
        return components.year ?? 0
    }
    
    public func timeTruncatedDate() -> Date? {
        let calendar = Calendar.current
        let component = calendar.dateComponents([.year , .month , .day], from: self)
        return calendar.date(from: component)
    }
    
    public func stringForDate() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        return dateFormatter.string(from: self)
    }
}
