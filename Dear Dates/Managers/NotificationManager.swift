//
//  NotificationManager.swift
//  DearDates
//
//  Created on 2025
//

import Foundation
import SwiftUI
import Combine
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                AppLogger.log("Notification authorization error: \(error.localizedDescription)", level: .error, category: "NotificationManager")
            } else if granted {
                AppLogger.log("Notification authorization granted", level: .info, category: "NotificationManager")
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
        
        let calendar = Calendar.current
        let nextBirthday = profile.nextBirthday
        
        // Уведомление в день рождения
        scheduleBirthdayNotification(for: profile, on: nextBirthday)
        
        // Уведомления за N дней до дня рождения
        for days in profile.reminderDays {
            guard let reminderDate = calendar.date(byAdding: .day, value: -days, to: nextBirthday) else {
                continue
            }
            
            // Планируем только если дата в будущем
            if reminderDate > Date() {
                scheduleReminderNotification(for: profile, days: days, on: reminderDate)
            }
        }
    }
    
    private func scheduleBirthdayNotification(for profile: Profile, on date: Date) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notification.birthday.title", value: "День рождения!", comment: "Birthday notification title")
        content.body = String(format: NSLocalizedString("notification.birthday.body", value: "Сегодня день рождения у %@! 🎉", comment: "Birthday notification body"), profile.name)
        content.sound = .default
        content.badge = 1
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let identifier = "birthday_\(profile.id.uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                AppLogger.log("Error scheduling birthday notification: \(error.localizedDescription)", level: .error, category: "NotificationManager")
            }
        }
    }
    
    private func scheduleReminderNotification(for profile: Profile, days: Int, on date: Date) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notification.reminder.title", value: "Напоминание о дне рождения", comment: "Reminder notification title")
        let daysText = daysText(days)
        content.body = String(format: NSLocalizedString("notification.reminder.body", value: "Через %d %@ день рождения у %@", comment: "Reminder notification body"), days, daysText, profile.name)
        content.sound = .default
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let identifier = "reminder_\(profile.id.uuidString)_\(days)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                AppLogger.log("Error scheduling reminder notification: \(error.localizedDescription)", level: .error, category: "NotificationManager")
            }
        }
    }
    
    func cancelNotifications(for profile: Profile) {
        var identifiers: [String] = []
        
        // Удаляем уведомление о дне рождения
        identifiers.append("birthday_\(profile.id.uuidString)")
        
        // Удаляем все напоминания
        for days in profile.reminderDays {
            identifiers.append("reminder_\(profile.id.uuidString)_\(days)")
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
    
    private func daysText(_ days: Int) -> String {
        switch days {
        case 1:
            return "день"
        case 2, 3, 4:
            return "дня"
        default:
            return "дней"
        }
    }
}

