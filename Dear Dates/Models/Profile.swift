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
    var avatarColorHue: Double // Сохраненный цвет аватарки (hue компонент HSV)
    var isFavorite: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), 
         name: String, 
         dateOfBirth: Date, 
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
        self.dateOfBirth = dateOfBirth
        self.photoPath = photoPath
        self.notes = notes
        self.notificationsEnabled = notificationsEnabled
        self.reminderDays = reminderDays
        self.isFavorite = isFavorite
        // Генерируем цвет на основе UUID, если не указан
        if let hue = avatarColorHue {
            self.avatarColorHue = hue
        } else {
            // Генерируем стабильный цвет на основе UUID
            let hash = id.uuidString.hashValue
            self.avatarColorHue = Double(abs(hash) % 360) / 360.0
        }
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, dateOfBirth, photoPath, notes, notificationsEnabled
        case reminderDays, avatarColorHue, isFavorite, createdAt, updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        dateOfBirth = try container.decode(Date.self, forKey: .dateOfBirth)
        photoPath = try container.decodeIfPresent(String.self, forKey: .photoPath)
        notes = try container.decode(String.self, forKey: .notes)
        notificationsEnabled = try container.decode(Bool.self, forKey: .notificationsEnabled)
        reminderDays = try container.decode([Int].self, forKey: .reminderDays)
        
        // Если avatarColorHue отсутствует (старые профили), генерируем его из id
        if let hue = try? container.decode(Double.self, forKey: .avatarColorHue) {
            avatarColorHue = hue
        } else {
            let hash = id.uuidString.hashValue
            avatarColorHue = Double(abs(hash) % 360) / 360.0
        }
        
        // Если isFavorite отсутствует (старые профили), устанавливаем false
        if let favorite = try? container.decode(Bool.self, forKey: .isFavorite) {
            isFavorite = favorite
        } else {
            isFavorite = false
        }
        
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(dateOfBirth, forKey: .dateOfBirth)
        try container.encodeIfPresent(photoPath, forKey: .photoPath)
        try container.encode(notes, forKey: .notes)
        try container.encode(notificationsEnabled, forKey: .notificationsEnabled)
        try container.encode(reminderDays, forKey: .reminderDays)
        try container.encode(avatarColorHue, forKey: .avatarColorHue)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
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

