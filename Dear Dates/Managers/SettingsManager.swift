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
    
    @Published var iCloudSyncEnabled: Bool {
        didSet {
            saveSettings()
            // При изменении настройки iCloud нужно перезапустить приложение
            // для применения изменений в ModelContainer
            if oldValue != iCloudSyncEnabled {
                AppLogger.log("iCloud sync setting changed to: \(iCloudSyncEnabled)", level: .info, category: "SettingsManager")
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
            self.iCloudSyncEnabled = settings.iCloudSyncEnabled
        } else {
            self.themeType = .system
            self.accentColor = .pink
            self.notificationsEnabled = true
            self.iCloudSyncEnabled = false
        }
    }
    
    private func saveSettings() {
        let settings = AppSettings(themeType: themeType, accentColor: accentColor, notificationsEnabled: notificationsEnabled, iCloudSyncEnabled: iCloudSyncEnabled)
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }
}

