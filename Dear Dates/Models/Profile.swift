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
    var reminderDays: [Int] // [1, 3, 7, 14, 30]
    var avatarColorHue: Double
    var isFavorite: Bool
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(deleteRule: .cascade) var gifts: [Gift]?
    @Relationship(deleteRule: .cascade) var customEvents: [CustomEvent]?
    
    init(id: UUID = UUID(),
         name: String,
         photoPath: String? = nil,
         notes: String = "",
         notificationsEnabled: Bool = true,
         reminderDays: [Int] = [7, 1],
         avatarColorHue: Double? = nil,
         isFavorite: Bool = false,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.photoPath = photoPath
        self.notes = notes
        self.notificationsEnabled = notificationsEnabled
        self.reminderDays = reminderDays
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        
        // Генерируем цвет на основе UUID, если не указан
        if let hue = avatarColorHue {
            self.avatarColorHue = hue
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
        self.init(
            id: codable.id,
            name: codable.name,
            photoPath: codable.photoPath,
            notes: codable.notes,
            notificationsEnabled: codable.notificationsEnabled,
            reminderDays: codable.reminderDays,
            avatarColorHue: codable.avatarColorHue,
            isFavorite: codable.isFavorite,
            createdAt: codable.createdAt,
            updatedAt: codable.updatedAt
        )
    }
}
