//
//  CustomEvent.swift
//  DearDates
//
//  Created on 2026
//

import Foundation
import SwiftData

@Model
final class CustomEvent: Identifiable {
    @Attribute(.unique) var id: UUID
    var profileId: UUID
    var name: String
    var month: Int // 1-12
    var day: Int // 1-31
    var remindAnnually: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(),
         profileId: UUID,
         name: String,
         month: Int,
         day: Int,
         remindAnnually: Bool = true,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.profileId = profileId
        self.name = name
        self.month = month
        self.day = day
        self.remindAnnually = remindAnnually
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Вычисляемое свойство для получения следующей даты события
    var nextDate: Date {
        let calendar = Calendar.current
        let today = Date()
        let thisYear = calendar.component(.year, from: today)
        
        var components = DateComponents()
        components.year = thisYear
        components.month = month
        components.day = day
        
        guard let thisYearDate = calendar.date(from: components) else {
            return today
        }
        
        if thisYearDate >= today {
            return thisYearDate
        } else {
            components.year = thisYear + 1
            return calendar.date(from: components) ?? thisYearDate
        }
    }
    
    // Дней до события
    var daysUntil: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: Date(), to: nextDate).day ?? 0
        return max(0, days)
    }
    
    // Проверка, сегодня ли событие
    var isToday: Bool {
        let calendar = Calendar.current
        let today = calendar.dateComponents([.month, .day], from: Date())
        return today.month == month && today.day == day
    }
}

