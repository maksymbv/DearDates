//
//  AppSettings.swift
//  DearDates
//
//  Created on 2025
//

import Foundation
import SwiftUI
import Combine

enum AccentColor: String, Codable, CaseIterable {
    case pink = "pink"
    case blue = "blue"
    
    var color: Color {
        switch self {
        case .pink:
            return .pink
        case .blue:
            return .blue
        }
    }
}

struct AppSettings: Codable {
    var isDarkMode: Bool
    var accentColor: AccentColor
    var notificationsEnabled: Bool
    
    init(isDarkMode: Bool = false, accentColor: AccentColor = .pink, notificationsEnabled: Bool = true) {
        self.isDarkMode = isDarkMode
        self.accentColor = accentColor
        self.notificationsEnabled = notificationsEnabled
    }
}

