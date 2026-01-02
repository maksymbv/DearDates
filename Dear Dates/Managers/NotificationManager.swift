//
//  NotificationManager.swift
//  DearDates
//
//  Created on 2026
//

import Foundation
import SwiftUI
import Combine
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    private let localizationManager = LocalizationManager.shared
    
    private init() {
        checkAuthorizationStatus()
        requestAuthorization()
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    AppLogger.log("Notification authorization error: \(error.localizedDescription)", level: .error, category: "NotificationManager")
                    ErrorManager.shared.showError(.notificationPermissionDenied)
                } else if !granted {
                    AppLogger.log("Notification authorization denied by user", level: .warning, category: "NotificationManager")
                    ErrorManager.shared.showError(.notificationPermissionDenied)
                } else {
                    AppLogger.log("Notification authorization granted", level: .info, category: "NotificationManager")
                }
                self?.checkAuthorizationStatus()
            }
        }
    }
    
    func scheduleNotifications(for profile: Profile) {
        // Проверяем глобальное отключение уведомлений
        guard SettingsManager.shared.notificationsEnabled else {
            cancelNotifications(for: profile)
            return
        }
        
        guard profile.notificationsEnabled else {
            cancelNotifications(for: profile)
            return
        }
        
        // Проверяем статус разрешений
        guard authorizationStatus == .authorized else {
            AppLogger.log("Cannot schedule notifications: authorization status is \(authorizationStatus.rawValue)", level: .warning, category: "NotificationManager")
            // Не показываем ошибку здесь, так как это может быть нормальной ситуацией
            // Ошибка уже показана при запросе разрешений
            return
        }
        
        // Уведомления планируются только для пользовательских событий, если они есть
        // Эта функция вызывается при создании/обновлении профиля, но события могут быть добавлены позже
        // Уведомления для событий планируются отдельно при создании/обновлении события
    }
    
    func cancelNotifications(for profile: Profile) {
        // Сохраняем значения свойств в локальные переменные, чтобы избежать ошибок SwiftData
        let profileId = profile.id
        let reminderDays = profile.reminderDays
        cancelNotifications(profileId: profileId, reminderDays: reminderDays)
    }
    
    func cancelNotifications(profileId: UUID, reminderDays: [Int]) {
        var identifiers: [String] = []
        
        // Удаляем все напоминания для событий профиля
        for days in reminderDays {
            identifiers.append("reminder_\(profileId.uuidString)_\(days)")
        }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func updateNotifications(for profile: Profile) {
        cancelNotifications(for: profile)
        scheduleNotifications(for: profile)
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
}

