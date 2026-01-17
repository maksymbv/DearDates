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
        let calendar = Calendar.current // Calendar.current уже использует системный часовой пояс
        let today = Date()
        let thisYear = calendar.component(.year, from: today)
        
        // Получаем начало текущего дня для корректного сравнения
        let startOfToday = calendar.startOfDay(for: today)
        
        var components = DateComponents()
        components.year = thisYear
        components.month = month
        components.day = day
        components.hour = 12 // Устанавливаем полдень в локальном времени для избежания проблем с часовыми поясами
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone.current // Явно указываем системный часовой пояс
        
        guard let thisYearDate = calendar.date(from: components) else {
            return today
        }
        
        // Получаем начало дня события для сравнения
        let startOfEventDate = calendar.startOfDay(for: thisYearDate)
        
        // Сравниваем начала дней, а не полные даты с временем
        if startOfEventDate >= startOfToday {
            return thisYearDate
        } else {
            components.year = thisYear + 1
            return calendar.date(from: components) ?? thisYearDate
        }
    }
    
    // Дней до события
    var daysUntil: Int {
        let calendar = Calendar.current
        let now = Date()
        // Получаем начало текущего дня (00:00:00) в локальном времени
        let startOfToday = calendar.startOfDay(for: now)
        // Получаем начало дня события в локальном времени
        let startOfEventDate = calendar.startOfDay(for: nextDate)
        // Вычисляем разницу в днях между началами дней
        let days = calendar.dateComponents([.day], from: startOfToday, to: startOfEventDate).day ?? 0
        return max(0, days)
    }
    
    // Проверка, сегодня ли событие
    var isToday: Bool {
        let calendar = Calendar.current
        let now = Date()
        // Получаем начало текущего дня
        let startOfToday = calendar.startOfDay(for: now)
        // Получаем начало дня события
        let startOfEventDate = calendar.startOfDay(for: nextDate)
        // Сравниваем начала дней
        return calendar.isDate(startOfEventDate, inSameDayAs: startOfToday)
    }
}

