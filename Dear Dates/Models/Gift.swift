//
//  Gift.swift
//  DearDates
//
//  Created on 2026
//

import Foundation
import SwiftData

@Model
final class Gift: Identifiable, Equatable {
    @Attribute(.unique) var id: UUID
    var profileId: UUID
    var title: String
    var notes: String
    var isGiven: Bool
    var givenYear: Int?
    var eventId: UUID? // Привязка к событию
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(),
         profileId: UUID,
         title: String,
         notes: String = "",
         isGiven: Bool = false,
         givenYear: Int? = nil,
         eventId: UUID? = nil,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.profileId = profileId
        self.title = title
        self.notes = notes
        self.isGiven = isGiven
        self.givenYear = givenYear
        self.eventId = eventId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    static func == (lhs: Gift, rhs: Gift) -> Bool {
        lhs.id == rhs.id
    }
}

extension Gift {
    static func groupedByYear(_ gifts: [Gift]) -> [Int: [Gift]] {
        Dictionary(grouping: gifts.filter { $0.isGiven && $0.givenYear != nil }) { gift in
            gift.givenYear ?? 0
        }
    }
}

// MARK: - Codable для экспорта/импорта
struct GiftCodable: Codable {
    var id: UUID
    var profileId: UUID
    var title: String
    var notes: String
    var isGiven: Bool
    var givenYear: Int?
    var eventId: UUID?
    var createdAt: Date
    var updatedAt: Date
}

extension Gift {
    func toCodable() -> GiftCodable {
        GiftCodable(
            id: id,
            profileId: profileId,
            title: title,
            notes: notes,
            isGiven: isGiven,
            givenYear: givenYear,
            eventId: eventId,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    convenience init(from codable: GiftCodable) {
        self.init(
            id: codable.id,
            profileId: codable.profileId,
            title: codable.title,
            notes: codable.notes,
            isGiven: codable.isGiven,
            givenYear: codable.givenYear,
            eventId: codable.eventId,
            createdAt: codable.createdAt,
            updatedAt: codable.updatedAt
        )
    }
}
