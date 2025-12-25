//
//  Profile.swift
//  DearDates
//
//  Created on 2025
//

import Foundation

struct Profile: Identifiable, Codable {
    var id: UUID
    var name: String
    var dateOfBirth: Date
    var photoPath: String?
    var notes: String
    var notificationsEnabled: Bool
    var reminderDays: [Int] // [1, 3, 7, 14, 30]
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), 
         name: String, 
         dateOfBirth: Date, 
         photoPath: String? = nil, 
         notes: String = "", 
         notificationsEnabled: Bool = true,
         reminderDays: [Int] = [7, 1],
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.photoPath = photoPath
        self.notes = notes
        self.notificationsEnabled = notificationsEnabled
        self.reminderDays = reminderDays
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Вычисляемые свойства
    var age: Int {
        Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
    }
    
    var nextBirthday: Date {
        let calendar = Calendar.current
        let today = Date()
        let thisYear = calendar.component(.year, from: today)
        
        var components = calendar.dateComponents([.month, .day], from: dateOfBirth)
        components.year = thisYear
        
        guard let birthdayThisYear = calendar.date(from: components) else {
            return dateOfBirth
        }
        
        if birthdayThisYear >= today {
            return birthdayThisYear
        } else {
            components.year = thisYear + 1
            return calendar.date(from: components) ?? birthdayThisYear
        }
    }
    
    var daysUntilBirthday: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: Date(), to: nextBirthday).day ?? 0
        return max(0, days)
    }
    
    var isBirthdayToday: Bool {
        let calendar = Calendar.current
        let today = calendar.dateComponents([.month, .day], from: Date())
        let birthday = calendar.dateComponents([.month, .day], from: dateOfBirth)
        return today.month == birthday.month && today.day == birthday.day
    }
}

