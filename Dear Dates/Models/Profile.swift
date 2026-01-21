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
    @Attribute(.unique) var id: UUID
    var name: String
    var photoPath: String?
    var notes: String
    var notificationsEnabled: Bool
    @Attribute var _reminderDays: [Int]? // Внутреннее хранилище (опциональное для совместимости с миграцией)
    var avatarColorHue: Double
    var isFavorite: Bool
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(deleteRule: .cascade) var gifts: [Gift]?
    @Relationship(deleteRule: .cascade) var customEvents: [CustomEvent]?
    
    // Computed property для обратной совместимости - всегда возвращает неопциональное значение
    var reminderDays: [Int] {
        get {
            return _reminderDays ?? [7, 1]
        }
        set {
            _reminderDays = newValue
        }
    }
    
    init(id: UUID = UUID(),
         name: String,
         photoPath: String? = nil,
         notes: String = "",
         notificationsEnabled: Bool = true,
         reminderDays: [Int]? = [7, 1],
         avatarColorHue: Double? = nil,
         isFavorite: Bool = false,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.photoPath = photoPath
        self.notes = notes
        self.notificationsEnabled = notificationsEnabled
        self._reminderDays = reminderDays ?? [7, 1] // Дефолтное значение для совместимости
        self.isFavorite = isFavorite
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
    var isFavorite: Bool
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
            isFavorite: isFavorite,
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
            isFavorite: codable.isFavorite,
            createdAt: codable.createdAt,
            updatedAt: codable.updatedAt
        )
    }
}
