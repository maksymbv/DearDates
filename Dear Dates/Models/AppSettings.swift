//
//  AppSettings.swift
//  DearDates
//
//  Created on 2026
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

enum ThemeType: String, Codable, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

struct AppSettings: Codable {
    var themeType: ThemeType
    var accentColor: AccentColor
    var notificationsEnabled: Bool
    
    init(themeType: ThemeType = .system, accentColor: AccentColor = .pink, notificationsEnabled: Bool = true) {
        self.themeType = themeType
        self.accentColor = accentColor
        self.notificationsEnabled = notificationsEnabled
    }
    
    // Для обратной совместимости при декодировании старых настроек
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Пытаемся декодировать themeType
        if let themeType = try? container.decode(ThemeType.self, forKey: .themeType) {
            self.themeType = themeType
        } else if let isDarkMode = try? container.decode(Bool.self, forKey: .isDarkMode) {
            // Для обратной совместимости со старыми настройками
            self.themeType = isDarkMode ? .dark : .light
        } else {
            // По умолчанию используем системную тему
            self.themeType = .system
        }
        
        accentColor = try container.decode(AccentColor.self, forKey: .accentColor)
        notificationsEnabled = try container.decode(Bool.self, forKey: .notificationsEnabled)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(themeType, forKey: .themeType)
        try container.encode(accentColor, forKey: .accentColor)
        try container.encode(notificationsEnabled, forKey: .notificationsEnabled)
        // isDarkMode не кодируем, так как это вычисляемое свойство
    }
    
    enum CodingKeys: String, CodingKey {
        case themeType
        case isDarkMode // Используется только для чтения старых настроек
        case accentColor
        case notificationsEnabled
    }
}

