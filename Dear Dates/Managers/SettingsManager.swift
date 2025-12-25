//
//  SettingsManager.swift
//  DearDates
//
//  Created on 2025
//

import Foundation
import SwiftUI
import Combine

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var isDarkMode: Bool {
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
    
    private let settingsKey = "AppSettings"
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let settings = try? JSONDecoder().decode(AppSettings.self, from: data) {
            self.isDarkMode = settings.isDarkMode
            self.accentColor = settings.accentColor
            self.notificationsEnabled = settings.notificationsEnabled
        } else {
            self.isDarkMode = false
            self.accentColor = .pink
            self.notificationsEnabled = true
        }
    }
    
    private func saveSettings() {
        let settings = AppSettings(isDarkMode: isDarkMode, accentColor: accentColor, notificationsEnabled: notificationsEnabled)
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }
}

