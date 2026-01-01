//
//  DataManager.swift
//  DearDates
//
//  Created on 2025
//

import Foundation
import SwiftUI
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var profiles: [Profile] = []
    @Published var gifts: [Gift] = []
    @Published var userProfile: UserProfile = UserProfile()
    private let profilesKey = "SavedProfiles"
    private let giftsKey = "SavedGifts"
    private let userProfileKey = "UserProfile"
    
    private init() {
        loadData()
    }
    
    // MARK: - User Profile
    
    func updateUserProfile(_ profile: UserProfile) {
        var updatedProfile = profile
        updatedProfile.updatedAt = Date()
        userProfile = updatedProfile
        saveUserProfile()
    }
    
    func getUserProfile() -> UserProfile {
        return userProfile
    }
    
    private func saveUserProfile() {
        do {
            let encoded = try JSONEncoder().encode(userProfile)
            UserDefaults.standard.set(encoded, forKey: userProfileKey)
        } catch {
            AppLogger.log("Error saving user profile: \(error.localizedDescription)", level: .error, category: "DataManager")
        }
    }
    
    private func loadUserProfile() {
        if let data = UserDefaults.standard.data(forKey: userProfileKey) {
            do {
                userProfile = try JSONDecoder().decode(UserProfile.self, from: data)
            } catch {
                AppLogger.log("Error loading user profile: \(error.localizedDescription)", level: .error, category: "DataManager")
                userProfile = UserProfile()
            }
        }
    }
    
    // MARK: - Profiles
    
    func addProfile(_ profile: Profile) {
        profiles.append(profile)
        saveData()
    }
    
    func updateProfile(_ profile: Profile, notificationManager: NotificationManager) {
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            var updatedProfile = profile
            updatedProfile.updatedAt = Date()
            profiles[index] = updatedProfile
            // Обновляем уведомления
            notificationManager.updateNotifications(for: updatedProfile)
            saveData()
        }
    }
    
    func deleteProfile(_ profile: Profile, notificationManager: NotificationManager) {
        profiles.removeAll { $0.id == profile.id }
        // Удаляем все подарки этого профиля
        gifts.removeAll { $0.profileId == profile.id }
        // Удаляем уведомления профиля
        notificationManager.cancelNotifications(for: profile)
        saveData()
    }
    
    func getProfilesSortedByBirthday() -> [Profile] {
        profiles.sorted { profile1, profile2 in
            profile1.daysUntilBirthday < profile2.daysUntilBirthday
        }
    }
    
    // MARK: - Gifts
    
    func addGift(_ gift: Gift) {
        gifts.append(gift)
        saveData()
    }
    
    func updateGift(_ gift: Gift) {
        if let index = gifts.firstIndex(where: { $0.id == gift.id }) {
            var updatedGift = gift
            updatedGift.updatedAt = Date()
            gifts[index] = updatedGift
            saveData()
        }
    }
    
    func deleteGift(_ gift: Gift) {
        gifts.removeAll { $0.id == gift.id }
        saveData()
    }
    
    func getGifts(for profileId: UUID) -> [Gift] {
        gifts.filter { $0.profileId == profileId }
    }
    
    func getGivenGifts(for profileId: UUID) -> [Gift] {
        getGifts(for: profileId).filter { $0.isGiven }
    }
    
    func getGiftIdeas(for profileId: UUID) -> [Gift] {
        getGifts(for: profileId).filter { !$0.isGiven }
    }
    
    // MARK: - Persistence
    
    private func saveData() {
        // Сохраняем профили
        do {
            let encoded = try JSONEncoder().encode(profiles)
            UserDefaults.standard.set(encoded, forKey: profilesKey)
        } catch {
            AppLogger.log("Error saving profiles: \(error.localizedDescription)", level: .error, category: "DataManager")
        }
        
        // Сохраняем подарки
        do {
            let encoded = try JSONEncoder().encode(gifts)
            UserDefaults.standard.set(encoded, forKey: giftsKey)
        } catch {
            AppLogger.log("Error saving gifts: \(error.localizedDescription)", level: .error, category: "DataManager")
        }
    }
    
    private func loadData() {
        // Загружаем профили
        if let data = UserDefaults.standard.data(forKey: profilesKey) {
            do {
                profiles = try JSONDecoder().decode([Profile].self, from: data)
            } catch {
                AppLogger.log("Error loading profiles: \(error.localizedDescription)", level: .error, category: "DataManager")
                profiles = []
            }
        }
        
        // Загружаем подарки
        if let data = UserDefaults.standard.data(forKey: giftsKey) {
            do {
                gifts = try JSONDecoder().decode([Gift].self, from: data)
            } catch {
                AppLogger.log("Error loading gifts: \(error.localizedDescription)", level: .error, category: "DataManager")
                gifts = []
            }
        }
        
        // Загружаем профиль пользователя
        loadUserProfile()
    }
    
    // MARK: - Statistics
    
    func getTotalProfilesCount() -> Int {
        return profiles.count
    }
    
    func getTotalGiftIdeasCount() -> Int {
        return gifts.filter { !$0.isGiven }.count
    }
}

