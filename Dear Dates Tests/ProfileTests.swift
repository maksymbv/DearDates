//
//  ProfileTests.swift
//  Dear Dates Tests
//
//  Created on 2026
//

import XCTest
@testable import Dear_Dates

final class ProfileTests: XCTestCase {
    
    var calendar: Calendar!
    
    override func setUp() {
        super.setUp()
        calendar = Calendar.current
    }
    
    override func tearDown() {
        calendar = nil
        super.tearDown()
    }
    
    // MARK: - Age Tests
    
    func testAgeCalculation() {
        // Создаем профиль с датой рождения 25 лет назад
        let birthDate = calendar.date(byAdding: .year, value: -25, to: Date())!
        let profile = Profile(
            name: "Test User",
            dateOfBirth: birthDate
        )
        
        // Возраст должен быть примерно 25 (может быть 24 или 25 в зависимости от дня рождения)
        XCTAssertGreaterThanOrEqual(profile.age, 24)
        XCTAssertLessThanOrEqual(profile.age, 26)
    }
    
    // MARK: - Next Birthday Tests
    
    func testNextBirthdayThisYear() {
        // Создаем профиль с днем рождения через 30 дней
        let today = Date()
        let futureDate = calendar.date(byAdding: .day, value: 30, to: today)!
        let birthDate = calendar.date(byAdding: .year, value: -25, to: futureDate)!
        
        let profile = Profile(
            name: "Test User",
            dateOfBirth: birthDate
        )
        
        let nextBirthday = profile.nextBirthday
        let components = calendar.dateComponents([.month, .day], from: nextBirthday)
        let birthComponents = calendar.dateComponents([.month, .day], from: birthDate)
        
        XCTAssertEqual(components.month, birthComponents.month)
        XCTAssertEqual(components.day, birthComponents.day)
        XCTAssertGreaterThanOrEqual(nextBirthday, today)
    }
    
    func testNextBirthdayNextYear() {
        // Создаем профиль с днем рождения, который уже прошел в этом году
        let today = Date()
        let pastDate = calendar.date(byAdding: .day, value: -30, to: today)!
        let birthDate = calendar.date(byAdding: .year, value: -25, to: pastDate)!
        
        let profile = Profile(
            name: "Test User",
            dateOfBirth: birthDate
        )
        
        let nextBirthday = profile.nextBirthday
        let components = calendar.dateComponents([.month, .day], from: nextBirthday)
        let birthComponents = calendar.dateComponents([.month, .day], from: birthDate)
        
        XCTAssertEqual(components.month, birthComponents.month)
        XCTAssertEqual(components.day, birthComponents.day)
        XCTAssertGreaterThan(nextBirthday, today)
        
        // Проверяем, что это следующий год
        let nextBirthdayYear = calendar.component(.year, from: nextBirthday)
        let currentYear = calendar.component(.year, from: today)
        XCTAssertEqual(nextBirthdayYear, currentYear + 1)
    }
    
    func testNextBirthdayToday() {
        // Создаем профиль с днем рождения сегодня
        let today = Date()
        let birthDate = calendar.date(byAdding: .year, value: -25, to: today)!
        
        let profile = Profile(
            name: "Test User",
            dateOfBirth: birthDate
        )
        
        let nextBirthday = profile.nextBirthday
        let todayComponents = calendar.dateComponents([.month, .day], from: today)
        let birthdayComponents = calendar.dateComponents([.month, .day], from: nextBirthday)
        
        XCTAssertEqual(todayComponents.month, birthdayComponents.month)
        XCTAssertEqual(todayComponents.day, birthdayComponents.day)
    }
    
    // MARK: - Days Until Birthday Tests
    
    func testDaysUntilBirthday() {
        // Создаем профиль с днем рождения через 7 дней
        let today = Date()
        let futureDate = calendar.date(byAdding: .day, value: 7, to: today)!
        let birthDate = calendar.date(byAdding: .year, value: -25, to: futureDate)!
        
        let profile = Profile(
            name: "Test User",
            dateOfBirth: birthDate
        )
        
        let daysUntil = profile.daysUntilBirthday
        // Может быть 6 или 7 в зависимости от времени суток
        XCTAssertGreaterThanOrEqual(daysUntil, 6)
        XCTAssertLessThanOrEqual(daysUntil, 8)
    }
    
    func testDaysUntilBirthdayToday() {
        // Создаем профиль с днем рождения сегодня
        let today = Date()
        let birthDate = calendar.date(byAdding: .year, value: -25, to: today)!
        
        let profile = Profile(
            name: "Test User",
            dateOfBirth: birthDate
        )
        
        let daysUntil = profile.daysUntilBirthday
        XCTAssertEqual(daysUntil, 0)
    }
    
    // MARK: - Is Birthday Today Tests
    
    func testIsBirthdayToday() {
        // Создаем профиль с днем рождения сегодня
        let today = Date()
        let birthDate = calendar.date(byAdding: .year, value: -25, to: today)!
        
        let profile = Profile(
            name: "Test User",
            dateOfBirth: birthDate
        )
        
        XCTAssertTrue(profile.isBirthdayToday)
    }
    
    func testIsNotBirthdayToday() {
        // Создаем профиль с днем рождения не сегодня
        let today = Date()
        let futureDate = calendar.date(byAdding: .day, value: 7, to: today)!
        let birthDate = calendar.date(byAdding: .year, value: -25, to: futureDate)!
        
        let profile = Profile(
            name: "Test User",
            dateOfBirth: birthDate
        )
        
        XCTAssertFalse(profile.isBirthdayToday)
    }
    
    // MARK: - Edge Cases Tests
    
    func testLeapYearBirthday() {
        // Тест для дня рождения 29 февраля
        var components = DateComponents()
        components.year = 2000
        components.month = 2
        components.day = 29
        
        guard let leapYearDate = calendar.date(from: components) else {
            XCTFail("Failed to create leap year date")
            return
        }
        
        let profile = Profile(
            name: "Leap Year User",
            dateOfBirth: leapYearDate
        )
        
        // Проверяем, что nextBirthday вычисляется корректно
        let nextBirthday = profile.nextBirthday
        XCTAssertNotNil(nextBirthday)
        
        // В невисокосный год день рождения должен быть 28 февраля или 1 марта
        let nextBirthdayComponents = calendar.dateComponents([.month, .day], from: nextBirthday)
        let isFebruary28 = nextBirthdayComponents.month == 2 && nextBirthdayComponents.day == 28
        let isMarch1 = nextBirthdayComponents.month == 3 && nextBirthdayComponents.day == 1
        
        XCTAssertTrue(isFebruary28 || isMarch1, "Leap year birthday should be handled correctly")
    }
    
    func testVeryOldBirthday() {
        // Тест для очень старой даты рождения (100 лет назад)
        let oldDate = calendar.date(byAdding: .year, value: -100, to: Date())!
        
        let profile = Profile(
            name: "Old User",
            dateOfBirth: oldDate
        )
        
        XCTAssertEqual(profile.age, 100)
        XCTAssertNotNil(profile.nextBirthday)
    }
}

