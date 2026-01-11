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
        // Эта функция вызывается при создании/обновлении профиля
        // Уведомления для событий планируются отдельно при создании/обновлении события
        // Здесь мы ничего не делаем, так как уведомления планируются на уровне событий
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
    
    // MARK: - Event Notifications
    
    /// Планирует уведомления для события
    /// Использует NotificationSnapshotManager для сохранения данных (не читает основную БД)
    func scheduleNotifications(for event: CustomEvent, profileName: String, reminderDays: [Int]) {
        // Проверяем глобальное отключение уведомлений
        guard SettingsManager.shared.notificationsEnabled else {
            cancelNotifications(for: event)
            return
        }
        
        // Проверяем статус разрешений
        guard authorizationStatus == .authorized else {
            AppLogger.log("Cannot schedule notifications: authorization status is \(authorizationStatus.rawValue)", level: .warning, category: "NotificationManager")
            return
        }
        
        // Проверяем, что событие должно напоминаться
        guard event.remindAnnually else {
            cancelNotifications(for: event)
            return
        }
        
        let eventDate = event.nextDate
        let calendar = Calendar.current
        
        // Планируем уведомления для каждого дня напоминания
        for reminderDaysValue in reminderDays {
            // Вычисляем дату уведомления (за N дней до события)
            guard let notificationDate = calendar.date(byAdding: .day, value: -reminderDaysValue, to: eventDate) else {
                continue
            }
            
            // Пропускаем уведомления, которые должны были прийти в прошлом
            if notificationDate < Date() {
                continue
            }
            
            // Создаем snapshot item для сохранения данных
            let snapshotItem = NotificationSnapshotItem(
                eventId: event.id,
                profileId: event.profileId,
                eventName: event.name,
                notificationDate: notificationDate,
                reminderDays: reminderDaysValue
            )
            NotificationSnapshotManager.shared.addItem(snapshotItem)
            
            // Создаем уведомление
            let content = UNMutableNotificationContent()
            
            if reminderDaysValue == 0 {
                // Уведомление на день события
                content.title = "notification.event.title".localized
                let bodyFormat = "notification.event.body".localized
                content.body = String(format: bodyFormat, profileName)
            } else {
                // Уведомление-напоминание
                content.title = "notification.reminder.title".localized
                let daysText = localizationManager.daysText(reminderDaysValue)
                let bodyFormat = "notification.reminder.body".localized
                // Формат: "Через %d %@ событие у %@" или "In %d %@ is %@'s event"
                // Нужно правильно подставить значения
                content.body = String(format: bodyFormat, reminderDaysValue, daysText, profileName)
            }
            
            content.sound = .default
            content.badge = NSNumber(value: 1)
            
            // Создаем триггер на нужную дату (9:00 утра по умолчанию)
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: notificationDate)
            dateComponents.hour = 9
            dateComponents.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            // Создаем запрос на уведомление
            let identifier = "event_\(event.id.uuidString)_\(reminderDaysValue)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            // Планируем уведомление
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    AppLogger.log("Failed to schedule notification: \(error.localizedDescription)", level: .error, category: "NotificationManager")
                } else {
                    AppLogger.log("Notification scheduled for event \(event.id) on \(notificationDate)", level: .info, category: "NotificationManager")
                }
            }
        }
    }
    
    /// Отменяет уведомления для события
    func cancelNotifications(for event: CustomEvent) {
        // Удаляем из snapshot
        NotificationSnapshotManager.shared.removeItems(forEventId: event.id)
        
        // Отменяем запланированные уведомления
        var identifiers: [String] = []
        
        // Создаем идентификаторы для всех возможных дней напоминания (на случай, если reminderDays изменились)
        for days in 0...365 {
            identifiers.append("event_\(event.id.uuidString)_\(days)")
        }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    /// Отменяет все уведомления для профиля
    func cancelNotificationsForProfile(profileId: UUID) {
        // Удаляем из snapshot
        NotificationSnapshotManager.shared.removeItems(forProfileId: profileId)
        
        // Отменяем все уведомления для этого профиля
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiers = requests
                .filter { $0.identifier.contains(profileId.uuidString) }
                .map { $0.identifier }
            
            if !identifiers.isEmpty {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
            }
        }
    }
    
}

