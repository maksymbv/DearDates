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
    @Published var groups: [Group] = []
    
    private let profilesKey = "SavedProfiles"
    private let giftsKey = "SavedGifts"
    private let groupsKey = "SavedGroups"
    
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
    
    // MARK: - Groups
    
    func addGroup(_ group: Group) {
        groups.append(group)
        saveData()
    }
    
    func updateGroup(_ group: Group) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            var updatedGroup = group
            updatedGroup.updatedAt = Date()
            groups[index] = updatedGroup
            saveData()
        }
    }
    
    func deleteGroup(_ group: Group) {
        // Удаляем группу
        groups.removeAll { $0.id == group.id }
        
        // Удаляем groupId у всех профилей, которые были в этой группе
        for i in 0..<profiles.count {
            if profiles[i].groupId == group.id {
                profiles[i].groupId = nil
            }
        }
        
        saveData()
    }
    
    func getGroup(for groupId: UUID?) -> Group? {
        guard let groupId = groupId else { return nil }
        return groups.first { $0.id == groupId }
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
        
        // Сохраняем группы
        if let encoded = try? JSONEncoder().encode(groups) {
            UserDefaults.standard.set(encoded, forKey: groupsKey)
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
        
        // Загружаем группы
        if let data = UserDefaults.standard.data(forKey: groupsKey),
           let decoded = try? JSONDecoder().decode([Group].self, from: data) {
            groups = decoded
        }
    }
}

