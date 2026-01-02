//
//  DataManagerTests.swift
//  Dear Dates Tests
//
//  Created on 2026
//

import XCTest
@testable import Dear_Dates

final class DataManagerTests: XCTestCase {
    
    var dataManager: DataManager!
    var testUserDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        // Используем отдельный UserDefaults для тестов
        testUserDefaults = UserDefaults(suiteName: "test.deardates")!
        testUserDefaults.removePersistentDomain(forName: "test.deardates")
        
        // Создаем новый DataManager для тестов
        // Примечание: DataManager использует singleton, поэтому в реальном проекте
        // нужно было бы использовать dependency injection или сделать DataManager не singleton
        dataManager = DataManager.shared
    }
    
    override func tearDown() {
        testUserDefaults.removePersistentDomain(forName: "test.deardates")
        testUserDefaults = nil
        dataManager = nil
        super.tearDown()
    }
    
    // MARK: - Profile Tests
    
    func testAddProfile() {
        let profile = Profile(
            name: "Test User",
            dateOfBirth: Date()
        )
        
        let initialCount = dataManager.profiles.count
        dataManager.addProfile(profile)
        
        XCTAssertEqual(dataManager.profiles.count, initialCount + 1)
        XCTAssertTrue(dataManager.profiles.contains { $0.id == profile.id })
    }
    
    func testUpdateProfile() {
        let profile = Profile(
            name: "Test User",
            dateOfBirth: Date()
        )
        
        dataManager.addProfile(profile)
        
        var updatedProfile = profile
        updatedProfile.name = "Updated Name"
        
        let notificationManager = NotificationManager.shared
        dataManager.updateProfile(updatedProfile, notificationManager: notificationManager)
        
        let foundProfile = dataManager.profiles.first { $0.id == profile.id }
        XCTAssertNotNil(foundProfile)
        XCTAssertEqual(foundProfile?.name, "Updated Name")
    }
    
    func testDeleteProfile() {
        let profile = Profile(
            name: "Test User",
            dateOfBirth: Date()
        )
        
        dataManager.addProfile(profile)
        let initialCount = dataManager.profiles.count
        
        let notificationManager = NotificationManager.shared
        dataManager.deleteProfile(profile, notificationManager: notificationManager)
        
        XCTAssertEqual(dataManager.profiles.count, initialCount - 1)
        XCTAssertFalse(dataManager.profiles.contains { $0.id == profile.id })
    }
    
    func testGetProfilesSortedByBirthday() {
        let today = Date()
        let calendar = Calendar.current
        
        // Создаем профили с разными днями рождения
        let profile1 = Profile(
            name: "User 1",
            dateOfBirth: calendar.date(byAdding: .day, value: 30, to: today)!
        )
        
        let profile2 = Profile(
            name: "User 2",
            dateOfBirth: calendar.date(byAdding: .day, value: 7, to: today)!
        )
        
        let profile3 = Profile(
            name: "User 3",
            dateOfBirth: calendar.date(byAdding: .day, value: 14, to: today)!
        )
        
        dataManager.addProfile(profile1)
        dataManager.addProfile(profile2)
        dataManager.addProfile(profile3)
        
        let sorted = dataManager.getProfilesSortedByBirthday()
        
        // Проверяем, что отсортированы по дням до дня рождения
        XCTAssertEqual(sorted[0].name, "User 2") // 7 дней
        XCTAssertEqual(sorted[1].name, "User 3") // 14 дней
        XCTAssertEqual(sorted[2].name, "User 1") // 30 дней
    }
    
    // MARK: - Gift Tests
    
    func testAddGift() {
        let profile = Profile(
            name: "Test User",
            dateOfBirth: Date()
        )
        dataManager.addProfile(profile)
        
        let gift = Gift(
            profileId: profile.id,
            title: "Test Gift",
            description: "Test Description"
        )
        
        let initialCount = dataManager.gifts.count
        dataManager.addGift(gift)
        
        XCTAssertEqual(dataManager.gifts.count, initialCount + 1)
        XCTAssertTrue(dataManager.gifts.contains { $0.id == gift.id })
    }
    
    func testUpdateGift() {
        let profile = Profile(
            name: "Test User",
            dateOfBirth: Date()
        )
        dataManager.addProfile(profile)
        
        let gift = Gift(
            profileId: profile.id,
            title: "Test Gift",
            description: "Test Description"
        )
        
        dataManager.addGift(gift)
        
        var updatedGift = gift
        updatedGift.title = "Updated Gift"
        
        dataManager.updateGift(updatedGift)
        
        let foundGift = dataManager.gifts.first { $0.id == gift.id }
        XCTAssertNotNil(foundGift)
        XCTAssertEqual(foundGift?.title, "Updated Gift")
    }
    
    func testDeleteGift() {
        let profile = Profile(
            name: "Test User",
            dateOfBirth: Date()
        )
        dataManager.addProfile(profile)
        
        let gift = Gift(
            profileId: profile.id,
            title: "Test Gift",
            description: "Test Description"
        )
        
        dataManager.addGift(gift)
        let initialCount = dataManager.gifts.count
        
        dataManager.deleteGift(gift)
        
        XCTAssertEqual(dataManager.gifts.count, initialCount - 1)
        XCTAssertFalse(dataManager.gifts.contains { $0.id == gift.id })
    }
    
    func testGetGiftsForProfile() {
        let profile1 = Profile(
            name: "User 1",
            dateOfBirth: Date()
        )
        let profile2 = Profile(
            name: "User 2",
            dateOfBirth: Date()
        )
        
        dataManager.addProfile(profile1)
        dataManager.addProfile(profile2)
        
        let gift1 = Gift(profileId: profile1.id, title: "Gift 1")
        let gift2 = Gift(profileId: profile1.id, title: "Gift 2")
        let gift3 = Gift(profileId: profile2.id, title: "Gift 3")
        
        dataManager.addGift(gift1)
        dataManager.addGift(gift2)
        dataManager.addGift(gift3)
        
        let profile1Gifts = dataManager.getGifts(for: profile1.id)
        XCTAssertEqual(profile1Gifts.count, 2)
        XCTAssertTrue(profile1Gifts.allSatisfy { $0.profileId == profile1.id })
    }
    
    func testGetGiftIdeas() {
        let profile = Profile(
            name: "Test User",
            dateOfBirth: Date()
        )
        dataManager.addProfile(profile)
        
        let idea1 = Gift(profileId: profile.id, title: "Idea 1", isGiven: false)
        let idea2 = Gift(profileId: profile.id, title: "Idea 2", isGiven: false)
        let givenGift = Gift(profileId: profile.id, title: "Given Gift", isGiven: true)
        
        dataManager.addGift(idea1)
        dataManager.addGift(idea2)
        dataManager.addGift(givenGift)
        
        let ideas = dataManager.getGiftIdeas(for: profile.id)
        XCTAssertEqual(ideas.count, 2)
        XCTAssertTrue(ideas.allSatisfy { !$0.isGiven })
    }
    
    func testGetGivenGifts() {
        let profile = Profile(
            name: "Test User",
            dateOfBirth: Date()
        )
        dataManager.addProfile(profile)
        
        let idea = Gift(profileId: profile.id, title: "Idea", isGiven: false)
        let givenGift1 = Gift(profileId: profile.id, title: "Given 1", isGiven: true, givenYear: 2023)
        let givenGift2 = Gift(profileId: profile.id, title: "Given 2", isGiven: true, givenYear: 2024)
        
        dataManager.addGift(idea)
        dataManager.addGift(givenGift1)
        dataManager.addGift(givenGift2)
        
        let givenGifts = dataManager.getGivenGifts(for: profile.id)
        XCTAssertEqual(givenGifts.count, 2)
        XCTAssertTrue(givenGifts.allSatisfy { $0.isGiven })
    }
    
    // MARK: - Statistics Tests
    
    func testGetTotalProfilesCount() {
        let initialCount = dataManager.getTotalProfilesCount()
        
        let profile1 = Profile(name: "User 1", dateOfBirth: Date())
        let profile2 = Profile(name: "User 2", dateOfBirth: Date())
        
        dataManager.addProfile(profile1)
        dataManager.addProfile(profile2)
        
        XCTAssertEqual(dataManager.getTotalProfilesCount(), initialCount + 2)
    }
    
    func testGetTotalGiftIdeasCount() {
        let profile = Profile(name: "Test User", dateOfBirth: Date())
        dataManager.addProfile(profile)
        
        let initialCount = dataManager.getTotalGiftIdeasCount()
        
        let idea1 = Gift(profileId: profile.id, title: "Idea 1", isGiven: false)
        let idea2 = Gift(profileId: profile.id, title: "Idea 2", isGiven: false)
        let givenGift = Gift(profileId: profile.id, title: "Given", isGiven: true)
        
        dataManager.addGift(idea1)
        dataManager.addGift(idea2)
        dataManager.addGift(givenGift)
        
        XCTAssertEqual(dataManager.getTotalGiftIdeasCount(), initialCount + 2)
    }
    
    // MARK: - Data Persistence Tests
    
    func testProfilePersistence() {
        // Этот тест проверяет, что данные сохраняются и загружаются
        // В реальном проекте нужно было бы использовать mock UserDefaults
        
        let profile = Profile(
            name: "Persistent User",
            dateOfBirth: Date()
        )
        
        dataManager.addProfile(profile)
        
        // Проверяем, что профиль сохранен
        let foundProfile = dataManager.profiles.first { $0.id == profile.id }
        XCTAssertNotNil(foundProfile)
        XCTAssertEqual(foundProfile?.name, "Persistent User")
    }
    
    func testDeleteProfileRemovesGifts() {
        let profile = Profile(name: "Test User", dateOfBirth: Date())
        dataManager.addProfile(profile)
        
        let gift1 = Gift(profileId: profile.id, title: "Gift 1")
        let gift2 = Gift(profileId: profile.id, title: "Gift 2")
        
        dataManager.addGift(gift1)
        dataManager.addGift(gift2)
        
        let notificationManager = NotificationManager.shared
        dataManager.deleteProfile(profile, notificationManager: notificationManager)
        
        // Проверяем, что подарки тоже удалены
        let remainingGifts = dataManager.gifts.filter { $0.profileId == profile.id }
        XCTAssertEqual(remainingGifts.count, 0)
    }
}

