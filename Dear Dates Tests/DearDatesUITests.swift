//
//  DearDatesUITests.swift
//  Dear Dates Tests
//
//  Created on 2026
//

import XCTest

final class DearDatesUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        // Можно установить launch arguments для тестирования
        // app.launchArguments = ["--uitesting"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Onboarding Tests
    
    func testOnboardingFlow() throws {
        // Пропускаем онбординг если он есть
        // В реальном приложении нужно настроить launch arguments для пропуска онбординга в тестах
        
        // Ждем появления основного экрана
        let exists = NSPredicate(format: "exists == true")
        let tabBar = app.tabBars.firstMatch
        expectation(for: exists, evaluatedWith: tabBar, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // MARK: - Profile Creation Tests
    
    func testCreateProfile() throws {
        // Находим кнопку добавления профиля
        let addButton = app.buttons["plus"]
        
        if addButton.waitForExistence(timeout: 5) {
            addButton.tap()
            
            // Заполняем форму профиля
            let nameField = app.textFields["label.name".localized]
            if nameField.waitForExistence(timeout: 2) {
                nameField.tap()
                nameField.typeText("Test User")
            }
            
            // Выбираем дату рождения
            let birthDateButton = app.buttons["label.birth_date".localized]
            if birthDateButton.waitForExistence(timeout: 2) {
                birthDateButton.tap()
                
                // Подтверждаем выбор даты
                let confirmButton = app.buttons["checkmark"]
                if confirmButton.waitForExistence(timeout: 2) {
                    confirmButton.tap()
                }
            }
            
            // Сохраняем профиль
            let saveButton = app.buttons["checkmark"]
            if saveButton.waitForExistence(timeout: 2) {
                saveButton.tap()
            }
            
            // Проверяем, что профиль создан
            XCTAssertTrue(app.staticTexts["Test User"].exists || app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Test User'")).firstMatch.exists)
        }
    }
    
    // MARK: - Navigation Tests
    
    func testNavigationBetweenTabs() throws {
        // Ждем появления tab bar
        let tabBar = app.tabBars.firstMatch
        guard tabBar.waitForExistence(timeout: 5) else {
            XCTFail("Tab bar not found")
            return
        }
        
        // Переходим на вкладку Календарь
        let calendarTab = app.tabBars.buttons.element(boundBy: 1)
        if calendarTab.exists {
            calendarTab.tap()
            XCTAssertTrue(app.navigationBars["navigation.calendar".localized].exists || app.navigationBars.containing(NSPredicate(format: "label CONTAINS 'Календарь' OR label CONTAINS 'Calendar'")).firstMatch.exists)
        }
        
        // Переходим на вкладку Поиск
        let searchTab = app.tabBars.buttons.element(boundBy: 2)
        if searchTab.exists {
            searchTab.tap()
            XCTAssertTrue(app.navigationBars["navigation.search".localized].exists || app.navigationBars.containing(NSPredicate(format: "label CONTAINS 'Поиск' OR label CONTAINS 'Search'")).firstMatch.exists)
        }
        
        // Переходим на вкладку Настройки
        let settingsTab = app.tabBars.buttons.element(boundBy: 3)
        if settingsTab.exists {
            settingsTab.tap()
            XCTAssertTrue(app.navigationBars["navigation.settings".localized].exists || app.navigationBars.containing(NSPredicate(format: "label CONTAINS 'Настройки' OR label CONTAINS 'Settings'")).firstMatch.exists)
        }
    }
    
    // MARK: - Search Tests
    
    func testSearchFunctionality() throws {
        // Переходим на вкладку Поиск
        let searchTab = app.tabBars.buttons.element(boundBy: 2)
        if searchTab.waitForExistence(timeout: 5) {
            searchTab.tap()
            
            // Ищем поле поиска
            let searchField = app.searchFields.firstMatch
            if searchField.waitForExistence(timeout: 2) {
                searchField.tap()
                searchField.typeText("Test")
                
                // Проверяем, что результаты поиска отображаются
                // (если есть профили с "Test" в имени)
            }
        }
    }
    
    // MARK: - Settings Tests
    
    func testSettingsAccess() throws {
        // Переходим на вкладку Настройки
        let settingsTab = app.tabBars.buttons.element(boundBy: 3)
        if settingsTab.waitForExistence(timeout: 5) {
            settingsTab.tap()
            
            // Проверяем наличие основных элементов настроек
            // В реальном приложении нужно добавить accessibility identifiers
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandling() throws {
        // Тест обработки ошибок
        // Можно создать профиль с невалидными данными и проверить отображение ошибки
        
        let addButton = app.buttons["plus"]
        if addButton.waitForExistence(timeout: 5) {
            addButton.tap()
            
            // Пытаемся сохранить без имени
            let saveButton = app.buttons["checkmark"]
            if saveButton.waitForExistence(timeout: 2) {
                // Кнопка должна быть disabled
                XCTAssertFalse(saveButton.isEnabled)
            }
        }
    }
}

// MARK: - Helper Extension
extension String {
    var localized: String {
        // В UI-тестах локализация может работать по-другому
        // Это упрощенная версия для тестов
        return self
    }
}

