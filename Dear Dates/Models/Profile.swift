//
//  Profile.swift
//  DearDates
//
//  Created on 2026
//

import Foundation
import SwiftData

@Model
final class Profile: Identifiable {
    var id: UUID = UUID() // Дефолтное значение для CloudKit
    var name: String = "" // Дефолтное значение для CloudKit
    var photoPath: String?
    var notes: String = "" // Дефолтное значение для CloudKit
    var notificationsEnabled: Bool = true // Дефолтное значение для CloudKit
    var _reminderDaysData: String = "7,1" // Храним как строку для совместимости с CoreData
    var avatarColorHue: Double = 0.0 // Дефолтное значение для CloudKit
    var isPinned: Bool = false // Дефолтное значение для CloudKit
    var createdAt: Date = Date() // Дефолтное значение для CloudKit
    var updatedAt: Date = Date() // Дефолтное значение для CloudKit
    
    @Relationship(deleteRule: .cascade, inverse: \Gift.profile) var gifts: [Gift]? = [] // Опциональный для CloudKit
    @Relationship(deleteRule: .cascade, inverse: \CustomEvent.profile) var customEvents: [CustomEvent]? = [] // Опциональный для CloudKit
    
    // Computed property для обратной совместимости
    var reminderDays: [Int] {
        get {
            // Пытаемся распарсить строку
            let components = _reminderDaysData.split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            if !components.isEmpty {
                return components
            }
            // Если строка пустая или невалидная, возвращаем дефолт
            return [7, 1]
        }
        set {
            _reminderDaysData = newValue.isEmpty ? "7,1" : newValue.map { String($0) }.joined(separator: ",")
        }
    }
    
    init(id: UUID = UUID(),
         name: String,
         photoPath: String? = nil,
         notes: String = "",
         notificationsEnabled: Bool = true,
         reminderDays: [Int]? = [7, 1],
         avatarColorHue: Double? = nil,
         isPinned: Bool = false,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.photoPath = photoPath
        self.notes = notes
        self.notificationsEnabled = notificationsEnabled
        let days = reminderDays ?? [7, 1]
        self._reminderDaysData = days.isEmpty ? "7,1" : days.map { String($0) }.joined(separator: ",")
        self.isPinned = isPinned
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        
        // Генерируем цвет на основе UUID, если не указан
        if let hue = avatarColorHue, !hue.isNaN && hue.isFinite {
            self.avatarColorHue = max(0.0, min(1.0, hue)) // Ограничиваем диапазон 0-1
        } else {
            let hash = id.uuidString.hashValue
            self.avatarColorHue = Double(abs(hash) % 360) / 360.0
        }
        
        self.gifts = []
        self.customEvents = []
    }
}

// MARK: - Codable для экспорта/импорта
struct ProfileCodable: Codable {
    var id: UUID
    var name: String
    var photoPath: String?
    var notes: String
    var notificationsEnabled: Bool
    var reminderDays: [Int]
    var avatarColorHue: Double
    var isPinned: Bool
    var createdAt: Date
    var updatedAt: Date
}

extension Profile {
    func toCodable() -> ProfileCodable {
        ProfileCodable(
            id: id,
            name: name,
            photoPath: photoPath,
            notes: notes,
            notificationsEnabled: notificationsEnabled,
            reminderDays: reminderDays,
            avatarColorHue: avatarColorHue,
            isPinned: isPinned,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    convenience init(from codable: ProfileCodable) {
        // Валидация avatarColorHue: проверяем на NaN и бесконечность
        let safeHue: Double
        if codable.avatarColorHue.isNaN || !codable.avatarColorHue.isFinite {
            // Генерируем hue на основе ID, если значение невалидно
            let hash = codable.id.uuidString.hashValue
            safeHue = Double(abs(hash) % 360) / 360.0
        } else {
            safeHue = max(0.0, min(1.0, codable.avatarColorHue)) // Ограничиваем диапазон 0-1
        }
        
        self.init(
            id: codable.id,
            name: codable.name,
            photoPath: codable.photoPath,
            notes: codable.notes,
            notificationsEnabled: codable.notificationsEnabled,
            reminderDays: codable.reminderDays,
            avatarColorHue: safeHue,
            isPinned: codable.isPinned,
            createdAt: codable.createdAt,
            updatedAt: codable.updatedAt
        )
    }
}
