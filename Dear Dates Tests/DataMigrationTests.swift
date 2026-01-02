//
//  DataMigrationTests.swift
//  Dear Dates Tests
//
//  Created on 2026
//

import XCTest
@testable import Dear_Dates

final class DataMigrationTests: XCTestCase {
    
    // MARK: - Profile Migration Tests
    
    func testProfileMigrationWithoutAvatarColorHue() {
        // Тест обратной совместимости: профиль без avatarColorHue должен получить его из UUID
        let profileId = UUID()
        let jsonString = """
        {
            "id": "\(profileId.uuidString)",
            "name": "Test User",
            "dateOfBirth": 631152000,
            "photoPath": null,
            "notes": "",
            "notificationsEnabled": true,
            "reminderDays": [7, 1],
            "isFavorite": false,
            "createdAt": 631152000,
            "updatedAt": 631152000
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        
        do {
            let profile = try JSONDecoder().decode(Profile.self, from: jsonData)
            
            // Проверяем, что avatarColorHue был сгенерирован
            XCTAssertGreaterThanOrEqual(profile.avatarColorHue, 0.0)
            XCTAssertLessThanOrEqual(profile.avatarColorHue, 1.0)
            
            // Проверяем, что остальные поля загружены корректно
            XCTAssertEqual(profile.id, profileId)
            XCTAssertEqual(profile.name, "Test User")
        } catch {
            XCTFail("Failed to decode profile: \(error)")
        }
    }
    
    func testProfileMigrationWithoutIsFavorite() {
        // Тест обратной совместимости: профиль без isFavorite должен получить false
        let profileId = UUID()
        let jsonString = """
        {
            "id": "\(profileId.uuidString)",
            "name": "Test User",
            "dateOfBirth": 631152000,
            "photoPath": null,
            "notes": "",
            "notificationsEnabled": true,
            "reminderDays": [7, 1],
            "avatarColorHue": 0.5,
            "createdAt": 631152000,
            "updatedAt": 631152000
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        
        do {
            let profile = try JSONDecoder().decode(Profile.self, from: jsonData)
            
            // Проверяем, что isFavorite установлен в false по умолчанию
            XCTAssertFalse(profile.isFavorite)
        } catch {
            XCTFail("Failed to decode profile: \(error)")
        }
    }
    
    func testProfileMigrationWithAllFields() {
        // Тест, что профиль со всеми полями загружается корректно
        let profileId = UUID()
        let jsonString = """
        {
            "id": "\(profileId.uuidString)",
            "name": "Test User",
            "dateOfBirth": 631152000,
            "photoPath": "test.jpg",
            "notes": "Test notes",
            "notificationsEnabled": true,
            "reminderDays": [7, 1, 30],
            "avatarColorHue": 0.75,
            "isFavorite": true,
            "createdAt": 631152000,
            "updatedAt": 631152000
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        
        do {
            let profile = try JSONDecoder().decode(Profile.self, from: jsonData)
            
            XCTAssertEqual(profile.id, profileId)
            XCTAssertEqual(profile.name, "Test User")
            XCTAssertEqual(profile.photoPath, "test.jpg")
            XCTAssertEqual(profile.notes, "Test notes")
            XCTAssertTrue(profile.notificationsEnabled)
            XCTAssertEqual(profile.reminderDays, [7, 1, 30])
            XCTAssertEqual(profile.avatarColorHue, 0.75, accuracy: 0.01)
            XCTAssertTrue(profile.isFavorite)
        } catch {
            XCTFail("Failed to decode profile: \(error)")
        }
    }
    
    // MARK: - AppSettings Migration Tests
    
    func testAppSettingsMigrationFromIsDarkMode() {
        // Тест миграции старых настроек с isDarkMode на themeType
        let jsonString = """
        {
            "isDarkMode": true,
            "accentColor": "pink",
            "notificationsEnabled": true
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        
        do {
            let settings = try JSONDecoder().decode(AppSettings.self, from: jsonData)
            
            // Проверяем, что isDarkMode преобразован в themeType
            XCTAssertEqual(settings.themeType, .dark)
            XCTAssertEqual(settings.accentColor, .pink)
            XCTAssertTrue(settings.notificationsEnabled)
        } catch {
            XCTFail("Failed to decode AppSettings: \(error)")
        }
    }
    
    func testAppSettingsMigrationFromLightMode() {
        // Тест миграции светлой темы
        let jsonString = """
        {
            "isDarkMode": false,
            "accentColor": "blue",
            "notificationsEnabled": false
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        
        do {
            let settings = try JSONDecoder().decode(AppSettings.self, from: jsonData)
            
            XCTAssertEqual(settings.themeType, .light)
            XCTAssertEqual(settings.accentColor, .blue)
            XCTAssertFalse(settings.notificationsEnabled)
        } catch {
            XCTFail("Failed to decode AppSettings: \(error)")
        }
    }
    
    func testAppSettingsWithThemeType() {
        // Тест, что новые настройки с themeType загружаются корректно
        let jsonString = """
        {
            "themeType": "system",
            "accentColor": "pink",
            "notificationsEnabled": true
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        
        do {
            let settings = try JSONDecoder().decode(AppSettings.self, from: jsonData)
            
            XCTAssertEqual(settings.themeType, .system)
            XCTAssertEqual(settings.accentColor, .pink)
            XCTAssertTrue(settings.notificationsEnabled)
        } catch {
            XCTFail("Failed to decode AppSettings: \(error)")
        }
    }
    
    func testAppSettingsDefaultValues() {
        // Тест, что настройки без полей получают значения по умолчанию
        let jsonString = """
        {
            "accentColor": "pink",
            "notificationsEnabled": true
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        
        do {
            let settings = try JSONDecoder().decode(AppSettings.self, from: jsonData)
            
            // Если themeType отсутствует, должен использоваться system по умолчанию
            XCTAssertEqual(settings.themeType, .system)
        } catch {
            XCTFail("Failed to decode AppSettings: \(error)")
        }
    }
    
    // MARK: - Encoding Tests
    
    func testProfileEncoding() {
        // Тест, что профиль корректно кодируется
        let profile = Profile(
            name: "Test User",
            dateOfBirth: Date(),
            notes: "Test notes",
            notificationsEnabled: true,
            reminderDays: [7, 1],
            isFavorite: true
        )
        
        do {
            let encoded = try JSONEncoder().encode(profile)
            let decoded = try JSONDecoder().decode(Profile.self, from: encoded)
            
            XCTAssertEqual(decoded.id, profile.id)
            XCTAssertEqual(decoded.name, profile.name)
            XCTAssertEqual(decoded.notes, profile.notes)
            XCTAssertEqual(decoded.notificationsEnabled, profile.notificationsEnabled)
            XCTAssertEqual(decoded.reminderDays, profile.reminderDays)
            XCTAssertEqual(decoded.isFavorite, profile.isFavorite)
        } catch {
            XCTFail("Failed to encode/decode profile: \(error)")
        }
    }
    
    func testAppSettingsEncoding() {
        // Тест, что настройки корректно кодируются
        let settings = AppSettings(
            themeType: .dark,
            accentColor: .blue,
            notificationsEnabled: false
        )
        
        do {
            let encoded = try JSONEncoder().encode(settings)
            let decoded = try JSONDecoder().decode(AppSettings.self, from: encoded)
            
            XCTAssertEqual(decoded.themeType, settings.themeType)
            XCTAssertEqual(decoded.accentColor, settings.accentColor)
            XCTAssertEqual(decoded.notificationsEnabled, settings.notificationsEnabled)
        } catch {
            XCTFail("Failed to encode/decode AppSettings: \(error)")
        }
    }
}

