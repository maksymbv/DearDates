//
//  SettingsManager.swift
//  DearDates
//
//  Created on 2026
//

import Foundation
import SwiftUI
import Combine

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var themeType: ThemeType {
        didSet {
            saveSettings()
        }
    }
    
    @Published var accentColor: AccentColor {
        didSet {
            saveSettings()
        }
    }
    
    @Published var notificationsEnabled: Bool {
        didSet {
            saveSettings()
            if !notificationsEnabled {
                // Отключаем все уведомления при глобальном отключении
                NotificationManager.shared.cancelAllNotifications()
            }
        }
    }
    
    // Для обратной совместимости
    var isDarkMode: Bool {
        get {
            return themeType == .dark
        }
        set {
            themeType = newValue ? .dark : .light
        }
    }
    
    private let settingsKey = "AppSettings"
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let settings = try? JSONDecoder().decode(AppSettings.self, from: data) {
            self.themeType = settings.themeType
            self.accentColor = settings.accentColor
            self.notificationsEnabled = settings.notificationsEnabled
        } else {
            self.themeType = .system
            self.accentColor = .pink
            self.notificationsEnabled = true
        }
    }
    
    private func saveSettings() {
        let settings = AppSettings(themeType: themeType, accentColor: accentColor, notificationsEnabled: notificationsEnabled)
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }
}

