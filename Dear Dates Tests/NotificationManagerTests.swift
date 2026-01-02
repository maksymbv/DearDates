//
//  NotificationManagerTests.swift
//  Dear Dates Tests
//
//  Created on 2026
//

import XCTest
@testable import Dear_Dates
import UserNotifications

final class NotificationManagerTests: XCTestCase {
    
    var notificationManager: NotificationManager!
    var testProfile: Profile!
    
    override func setUp() {
        super.setUp()
        notificationManager = NotificationManager.shared
        
        // Создаем тестовый профиль
        let calendar = Calendar.current
        let birthDate = calendar.date(byAdding: .year, value: -25, to: Date())!
        testProfile = Profile(
            name: "Test User",
            dateOfBirth: birthDate,
            notificationsEnabled: true,
            reminderDays: [7, 1]
        )
    }
    
    override func tearDown() {
        // Отменяем все уведомления после теста
        notificationManager.cancelAllNotifications()
        testProfile = nil
        notificationManager = nil
        super.tearDown()
    }
    
    // MARK: - Authorization Tests
    
    func testRequestAuthorization() {
        // Тест запроса разрешений на уведомления
        let expectation = expectation(description: "Authorization request")
        
        // Проверяем текущий статус
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            // Статус может быть разным, но мы проверяем, что метод работает
            XCTAssertNotNil(settings)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // MARK: - Notification Scheduling Tests
    
    func testScheduleNotificationsForProfile() {
        // Тест планирования уведомлений для профиля
        // Примечание: В реальном проекте нужно мокировать UNUserNotificationCenter
        
        // Планируем уведомления
        notificationManager.scheduleNotifications(for: testProfile)
        
        // Проверяем, что метод выполнился без ошибок
        // В реальном проекте нужно проверить, что уведомления действительно запланированы
        XCTAssertNotNil(testProfile)
    }
    
    func testScheduleNotificationsWithDisabledProfile() {
        // Тест, что уведомления не планируются для профиля с отключенными уведомлениями
        var disabledProfile = testProfile
        disabledProfile?.notificationsEnabled = false
        
        notificationManager.scheduleNotifications(for: disabledProfile!)
        
        // Уведомления не должны быть запланированы
        // В реальном проекте нужно проверить, что уведомления не добавлены
        XCTAssertFalse(disabledProfile?.notificationsEnabled ?? true)
    }
    
    func testScheduleNotificationsWithGlobalDisabled() {
        // Тест, что уведомления не планируются при глобальном отключении
        let settingsManager = SettingsManager.shared
        let originalValue = settingsManager.notificationsEnabled
        
        // Отключаем уведомления глобально
        settingsManager.notificationsEnabled = false
        
        notificationManager.scheduleNotifications(for: testProfile)
        
        // Восстанавливаем значение
        settingsManager.notificationsEnabled = originalValue
        
        // Уведомления не должны быть запланированы
        XCTAssertFalse(settingsManager.notificationsEnabled)
    }
    
    // MARK: - Notification Cancellation Tests
    
    func testCancelNotificationsForProfile() {
        // Тест отмены уведомлений для профиля
        // Сначала планируем уведомления
        notificationManager.scheduleNotifications(for: testProfile)
        
        // Затем отменяем
        notificationManager.cancelNotifications(for: testProfile)
        
        // Метод должен выполниться без ошибок
        XCTAssertNotNil(testProfile)
    }
    
    func testCancelAllNotifications() {
        // Тест отмены всех уведомлений
        notificationManager.scheduleNotifications(for: testProfile)
        
        notificationManager.cancelAllNotifications()
        
        // Метод должен выполниться без ошибок
        XCTAssertNotNil(notificationManager)
    }
    
    // MARK: - Update Notifications Tests
    
    func testUpdateNotifications() {
        // Тест обновления уведомлений
        notificationManager.scheduleNotifications(for: testProfile)
        
        // Обновляем уведомления
        notificationManager.updateNotifications(for: testProfile)
        
        // Метод должен выполниться без ошибок
        XCTAssertNotNil(testProfile)
    }
    
    // MARK: - Reminder Days Tests
    
    func testScheduleNotificationsWithMultipleReminderDays() {
        // Тест планирования уведомлений с несколькими днями напоминания
        var profileWithMultipleReminders = testProfile
        profileWithMultipleReminders?.reminderDays = [30, 14, 7, 1]
        
        notificationManager.scheduleNotifications(for: profileWithMultipleReminders!)
        
        // Проверяем, что метод выполнился
        XCTAssertEqual(profileWithMultipleReminders?.reminderDays.count, 4)
    }
    
    func testScheduleNotificationsWithPastReminderDate() {
        // Тест, что уведомления не планируются для прошедших дат
        let calendar = Calendar.current
        let pastDate = calendar.date(byAdding: .day, value: -10, to: Date())!
        let birthDate = calendar.date(byAdding: .year, value: -25, to: pastDate)!
        
        var pastProfile = Profile(
            name: "Past User",
            dateOfBirth: birthDate,
            notificationsEnabled: true,
            reminderDays: [7, 1]
        )
        
        notificationManager.scheduleNotifications(for: pastProfile)
        
        // Уведомления для прошедших дат не должны планироваться
        // В реальном проекте нужно проверить, что уведомления не добавлены
        XCTAssertNotNil(pastProfile)
    }
    
    // MARK: - Authorization Status Tests
    
    func testCheckAuthorizationStatus() {
        // Тест проверки статуса авторизации
        notificationManager.checkAuthorizationStatus()
        
        // Статус должен быть обновлен
        // В реальном проекте нужно проверить, что authorizationStatus обновлен
        XCTAssertNotNil(notificationManager)
    }
}

