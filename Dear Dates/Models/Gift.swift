//
//  Gift.swift
//  DearDates
//
//  Created on 2025
//

import Foundation

struct Gift: Identifiable, Codable, Equatable {
    var id: UUID
    var profileId: UUID
    var title: String
    var description: String
    var isGiven: Bool
    var givenYear: Int?
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(),
         profileId: UUID,
         title: String,
         description: String = "",
         isGiven: Bool = false,
         givenYear: Int? = nil,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.profileId = profileId
        self.title = title
        self.description = description
        self.isGiven = isGiven
        self.givenYear = givenYear
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension Gift {
    static func groupedByYear(_ gifts: [Gift]) -> [Int: [Gift]] {
        Dictionary(grouping: gifts.filter { $0.isGiven && $0.givenYear != nil }) { gift in
            gift.givenYear ?? 0
        }
    }
}

