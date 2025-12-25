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
    
    private let profilesKey = "SavedProfiles"
    private let giftsKey = "SavedGifts"
    
    private init() {
        loadData()
    }
    
    // MARK: - Profiles
    
    func addProfile(_ profile: Profile) {
        profiles.append(profile)
        saveData()
    }
    
    func updateProfile(_ profile: Profile) {
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            var updatedProfile = profile
            updatedProfile.updatedAt = Date()
            profiles[index] = updatedProfile
            // Обновляем уведомления
            NotificationManager.shared.updateNotifications(for: updatedProfile)
            saveData()
        }
    }
    
    func deleteProfile(_ profile: Profile) {
        profiles.removeAll { $0.id == profile.id }
        // Удаляем все подарки этого профиля
        gifts.removeAll { $0.profileId == profile.id }
        // Удаляем уведомления профиля
        NotificationManager.shared.cancelNotifications(for: profile)
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
        if let encoded = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(encoded, forKey: profilesKey)
        }
        
        // Сохраняем подарки
        if let encoded = try? JSONEncoder().encode(gifts) {
            UserDefaults.standard.set(encoded, forKey: giftsKey)
        }
    }
    
    private func loadData() {
        // Загружаем профили
        if let data = UserDefaults.standard.data(forKey: profilesKey),
           let decoded = try? JSONDecoder().decode([Profile].self, from: data) {
            profiles = decoded
        }
        
        // Загружаем подарки
        if let data = UserDefaults.standard.data(forKey: giftsKey),
           let decoded = try? JSONDecoder().decode([Gift].self, from: data) {
            gifts = decoded
        }
    }
}

