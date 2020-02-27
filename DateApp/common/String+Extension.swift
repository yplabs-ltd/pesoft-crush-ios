//
//  String+Extension.swift
//  DateApp
//
//  Created by ryan on 12/27/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import Foundation

extension String {
    var isEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    // yyyy-MM-dd 확인 후 나이 문자열 반환
    var ageFromBirthDate: String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = dateFormatter.date(from: self) else {
            dateFormatter.dateFormat = "yyyy"
            if let d = dateFormatter.date(from: self) {
                return "\(getYearDifferenceFrom(date: d))세"
            }
            return ""
        }
        return "\(getYearDifferenceFrom(date: date))세"
    }
    
    private func getYearDifferenceFrom(date: Date) -> Int {
        let calendar = Calendar.current
        
        
        let todayComponent = calendar.dateComponents([.day, .month, .year], from: Date())
        let todayYear = todayComponent.year
        let birthComponents = calendar.dateComponents([.day, .month, .year], from: date)
        let birthYear = birthComponents.year
        let age = (todayYear ?? 0) - (birthYear ?? 0) + 1
        
        return age
    }
    
    // 현재시간에서 남은시간을 00:00:00 또는 몇일 이런식으로 string 반환
    static func stringHourMinSecFromTimeInterval(interval: TimeInterval) -> String {
        var interval = Int(interval)
        var future = false
        if interval < 0 {
            future = true
            interval *= -1
        }
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        let days = hours / 24
        if days != 0 {
            return stringDayCount(day: days)
        } else {
            if future {
                return String(format: "-%02d:%02d:%02d", hours, minutes, seconds)
            } else {
                return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            }
        }
    }
    
    static func stringHourMinFromTimeInterval(interval: TimeInterval, isFirstCell: Bool = false, expireDate: Date? = nil) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let date = Date()
        let calendar = Calendar.current
        
        let comp = calendar.dateComponents([.hour, .minute], from: date)
        let currentHour = comp.hour
        
        
        var interval = Int(interval)
        var future = false
        if interval < 0 {
            future = true
            interval *= -1
        }
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        
        if let exrDate = expireDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let currentCalendar = Calendar.current
            
            
            if let createDate = Calendar.current.date(byAdding: .hour, value: -24, to: exrDate) {
                let daysBetween = currentCalendar.dateComponents([.day], from: Date(), to: createDate)
                if daysBetween.day == 0 {
                    return "오늘"
                }else {
                    return "\(abs(daysBetween.day ?? 0))일전"
                }
            }
        }
        
        if future {
            return String(format: "다음 매칭때까지 %02d시간 %02d분 남음", hours, minutes)
        } else {
            let days = ( hours / 24 ) + 1
            return "\(days)일전"
        }
    }
    
    static func stringDayHourMinFromTimeInterval(interval: TimeInterval, expireDate: Date? = nil) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let date = Date()
        let calendar = Calendar.current
        
        let comp = calendar.dateComponents([.day, .hour, .minute], from: date)
        let currentHour = comp.hour
        
        
        var interval = Int(interval)
        var future = false
        if interval < 0 {
            future = true
            interval *= -1
        }
        
        let day = interval / 86400
        let minutes = (interval / 60) % 60
        let _hours = Int(interval / 3600) / 60
        let hours = _hours / 60
        
        if future {
            var remainString = ""
            if day > 0 {
                remainString += "\(day)일 "
            }
            
            if hours > 0 {
                remainString += "\(hours)시간 "
            }
            
            if minutes > 0 {
                remainString += "\(minutes)분 후 이벤트가 종료됩니다."
            }
            
            return remainString
        }
        
        return nil
    }
    
    static func stringDDayFromTimeInterval(interval: TimeInterval) -> String {
        var interval = Int(interval)
        var future = false
        if interval < 0 {
            future = true
            interval *= -1
        }
        let hours = (interval / 3600)
        let days = hours / 24
        if future {
            return String(format: "D-\(days)")
        } else {
            return String(format: "D+\(days)")
        }
    }
    
    static func isFutureDate(interval: TimeInterval) -> Bool {
        var interval = Int(interval)
        var future = false
        if interval < 0 {
            future = true
            interval *= -1
        }
        
        return future
    }
    
    
    // D-6 00:00:00 형식
    static func stringDDayAndTimeFromTimeInterval(interval: TimeInterval) -> String {
        var interval = Int(interval)
        var future = false
        if interval < 0 {
            future = true
            interval *= -1
        }
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600) % 24
        let days = (interval / 3600) / 24
        if future {
            return String(format: "D-\(days) %02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "D+\(days) %02d:%02d:%02d", hours, minutes, seconds)
        }
    }
    
    static func stringDayCount(day: Int) -> String {
        if 0 < day {
            if day == 1 {
                return "어제"
            } else {
                return "\(day)일전"
            }
        } else {
            if day == 1 {
                return "내일"
            } else {
                return "\(day)일후"
            }
        }
    }
    
    static func stringForMemberStatus(status: MemberStatus) -> String {
        
        switch status {
        case .Preview:
            return "프로필을 모두 입력한 후 승인을 요청해주세요"
        case .Normal:
            return "사진 변경은 관리자의 심사 후 적용됩니다"
        case .Blocked:
            return "승인 검토중입니다"
        case .Deleted:
            return "승인 검토중입니다"
        case .Waiting:
            return "승인 검토중입니다"
        }
    }
    
    var boolValue: Bool? {
        let trueValues = ["true", "yes", "1"]
        let falseValues = ["false", "no", "0"]
        
        let lowerSelf = self.lowercased()
        
        if trueValues.contains(lowerSelf) {
            return true
        } else if falseValues.contains(lowerSelf) {
            return false
        } else {
            return nil
        }
    }
    
    func trim() -> String {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func validPhoneNumberStream() -> Bool {
        if 11 != length {
            return false
        }
        if !hasPrefix("010") {
            return false
        }
        return true
    }
}


infix operator ?!
public func ?!<T: LengthConvertible>(optional: T?, defaultValue: @autoclosure () -> T) -> T {
    if let optional = optional, optional.length > 0 {
        return optional
    }
    
    return defaultValue()
}

public protocol LengthConvertible {
    var length: Int { get }
}

// Lengthable
extension StringLiteralType: LengthConvertible {
    public var length: Int {
        return self.count
    }
}

