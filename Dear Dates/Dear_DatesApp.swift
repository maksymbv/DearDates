//
//  DearDatesApp.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct DearDatesApp: App {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var settingsManager = SettingsManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var imageManager = ImageManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var errorManager = ErrorManager.shared
    
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "OnboardingCompleted")
    
    init() {
        setupAppInitialization()
    }
    
    var body: some Scene {
        WindowGroup {
            if showOnboarding {
                OnboardingView(isPresented: $showOnboarding)
                    .environmentObject(dataManager)
                    .environmentObject(settingsManager)
                    .environmentObject(localizationManager)
                    .environmentObject(imageManager)
                    .environmentObject(notificationManager)
                    .errorAlert()
            } else {
                ContentView()
                    .id("mainContentView")
                    .environmentObject(dataManager)
                    .environmentObject(notificationManager)
                    .environmentObject(settingsManager)
                    .environmentObject(localizationManager)
                    .environmentObject(imageManager)
                    .errorAlert()
            }
        }
        .modelContainer(for: [Profile.self, Gift.self, UserProfile.self, CustomEvent.self])
    }
    
    private func setupAppInitialization() {
        // Настраиваем делегат для обработки тапов на уведомления
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        
        // Настраиваем защиту базы данных (с задержкой, чтобы SwiftData успел создать файлы)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            DatabaseProtectionManager.shared.setupMainDatabaseProtection()
            DatabaseProtectionManager.shared.setupNotificationSnapshotProtection()
        }
    }
}

// MARK: - Notification Delegate
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Обработка тапа на уведомление
        completionHandler()
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Показываем уведомление даже когда приложение активно
        completionHandler([.banner, .sound, .badge])
    }
}
