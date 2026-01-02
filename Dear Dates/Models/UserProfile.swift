//
//  UserProfile.swift
//  DearDates
//
//  Created on 2026
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var name: String
    var photoPath: String?
    var updatedAt: Date
    var photoId: UUID?
    
    init(id: UUID = UUID(),
         name: String = "",
         photoPath: String? = nil,
         updatedAt: Date = Date(),
         photoId: UUID? = nil) {
        self.id = id
        self.name = name
        self.photoPath = photoPath
        self.updatedAt = updatedAt
        self.photoId = photoId
    }
}

// MARK: - Codable для экспорта/импорта
struct UserProfileCodable: Codable {
    var name: String
    var photoPath: String?
    var updatedAt: Date
    var photoId: UUID?
}

extension UserProfile {
    func toCodable() -> UserProfileCodable {
        UserProfileCodable(
            name: name,
            photoPath: photoPath,
            updatedAt: updatedAt,
            photoId: photoId
        )
    }
    
    convenience init(from codable: UserProfileCodable) {
        self.init(
            name: codable.name,
            photoPath: codable.photoPath,
            updatedAt: codable.updatedAt,
            photoId: codable.photoId
        )
    }
}
