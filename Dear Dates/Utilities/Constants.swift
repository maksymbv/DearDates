//
//  Constants.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI

struct AppConstants {
    struct TextLimits {
        static let maxProfileNameLength = 30
        static let maxEventNameLength = 50
        static let maxNotesLength = 500
        static let maxDescriptionLength = 10000
    }
    
    struct UI {
        static let notesFieldHeight: CGFloat = 150
        static let descriptionFieldHeight: CGFloat = 200
        static let animationDuration: Double = 0.3
    }
    
    struct Images {
        static let compressionQuality: CGFloat = 0.8
    }
}
