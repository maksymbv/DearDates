//
//  Group.swift
//  DearDates
//
//  Created on 2025
//

import Foundation

struct Group: Identifiable, Codable {
    var id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), 
         name: String, 
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
