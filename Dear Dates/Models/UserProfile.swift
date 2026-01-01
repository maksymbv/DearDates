//
//  UserProfile.swift
//  DearDates
//
//  Created on 2025
//

import Foundation

struct UserProfile: Codable {
    var name: String
    var photoPath: String?
    var updatedAt: Date
    var photoId: UUID?
    
    init(name: String = "", photoPath: String? = nil, updatedAt: Date = Date(), photoId: UUID? = nil) {
        self.name = name
        self.photoPath = photoPath
        self.updatedAt = updatedAt
        self.photoId = photoId
    }
}
