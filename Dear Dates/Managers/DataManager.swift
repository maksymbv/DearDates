//
//  DataManager.swift
//  DearDates
//
//  Created on 2026
//

import Foundation
import SwiftUI
import Combine
import SwiftData

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var isLoading: Bool = true
    
    private var modelContext: ModelContext?
    
    private init() {
        setupSwiftData()
    }
    
    // MARK: - SwiftData Setup
    
    func setupSwiftData() {
        let schema = Schema([
            Profile.self,
            Gift.self,
            UserProfile.self,
            CustomEvent.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            modelContext = ModelContext(container)
            
            // Данные теперь загружаются через @Query в Views
            isLoading = false
        } catch {
            AppLogger.log("Error setting up SwiftData: \(error.localizedDescription)", level: .error, category: "DataManager")
            ErrorManager.shared.showError(.dataLoadFailed(error.localizedDescription))
            isLoading = false
        }
    }
    
    // MARK: - User Profile
    
    func updateUserProfile(_ profile: UserProfile, context: ModelContext) {
        // ModelContext должен использоваться на главном потоке
        profile.updatedAt = Date()
        
        // Если профиль еще не в контексте, добавляем его
        // SwiftData автоматически обработает, если объект уже в контексте
        context.insert(profile)
        
        do {
            try context.save()
        } catch {
            let errorMessage = error.localizedDescription
            AppLogger.log("Error saving user profile: \(errorMessage)", level: .error, category: "DataManager")
            ErrorManager.shared.showError(.dataSaveFailed(errorMessage))
        }
    }
    
    // MARK: - Profiles
    
    func addProfile(_ profile: Profile, context: ModelContext) {
        context.insert(profile)
        
        do {
            try context.save()
        } catch {
            let errorMessage = error.localizedDescription
            AppLogger.log("Error saving profile: \(errorMessage)", level: .error, category: "DataManager")
            ErrorManager.shared.showError(.dataSaveFailed(errorMessage))
        }
    }
    
    func updateProfile(_ profile: Profile, notificationManager: NotificationManager, context: ModelContext) {
        // ModelContext должен использоваться на главном потоке
        profile.updatedAt = Date()
        
        do {
            try context.save()
            notificationManager.updateNotifications(for: profile)
        } catch {
            let errorMessage = error.localizedDescription
            AppLogger.log("Error updating profile: \(errorMessage)", level: .error, category: "DataManager")
            ErrorManager.shared.showError(.dataSaveFailed(errorMessage))
        }
    }
    
    func deleteProfile(_ profile: Profile, notificationManager: NotificationManager, context: ModelContext) {
        // Сохраняем данные профиля ДО удаления, чтобы избежать ошибок SwiftData
        let profileId = profile.id
        
        // Отменяем уведомления ДО удаления профиля из контекста (используем новый метод)
        notificationManager.cancelNotificationsForProfile(profileId: profileId)
        
        // Удаляем профиль из контекста
        context.delete(profile)
        
        do {
            try context.save()
        } catch {
            let errorMessage = error.localizedDescription
            AppLogger.log("Error deleting profile: \(errorMessage)", level: .error, category: "DataManager")
            ErrorManager.shared.showError(.dataSaveFailed(errorMessage))
        }
    }
    
    // MARK: - Gifts
    
    func addGift(_ gift: Gift, context: ModelContext) {
        context.insert(gift)
        
        do {
            try context.save()
        } catch {
            let errorMessage = error.localizedDescription
            AppLogger.log("Error saving gift: \(errorMessage)", level: .error, category: "DataManager")
            ErrorManager.shared.showError(.dataSaveFailed(errorMessage))
        }
    }
    
    func updateGift(_ gift: Gift, context: ModelContext) {
        // ModelContext должен использоваться на главном потоке
        gift.updatedAt = Date()
        
        do {
            try context.save()
        } catch {
            let errorMessage = error.localizedDescription
            AppLogger.log("Error updating gift: \(errorMessage)", level: .error, category: "DataManager")
            ErrorManager.shared.showError(.dataSaveFailed(errorMessage))
        }
    }
    
    func deleteGift(_ gift: Gift, context: ModelContext) {
        // ModelContext должен использоваться на главном потоке
        context.delete(gift)
        
        do {
            try context.save()
        } catch {
            let errorMessage = error.localizedDescription
            AppLogger.log("Error deleting gift: \(errorMessage)", level: .error, category: "DataManager")
            ErrorManager.shared.showError(.dataSaveFailed(errorMessage))
        }
    }
    
    func getGifts(for profileId: UUID, context: ModelContext) -> [Gift] {
        let descriptor = FetchDescriptor<Gift>(
            predicate: #Predicate { $0.profileId == profileId }
        )
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func getGivenGifts(for profileId: UUID, context: ModelContext) -> [Gift] {
        getGifts(for: profileId, context: context).filter { $0.isGiven }
    }
    
    func getGiftIdeas(for profileId: UUID, context: ModelContext) -> [Gift] {
        getGifts(for: profileId, context: context).filter { !$0.isGiven }
    }
    
    // MARK: - Data Loading
    
    
    // MARK: - Statistics
    
    func getTotalProfilesCount(context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<Profile>()
        return (try? context.fetch(descriptor).count) ?? 0
    }
    
    func getTotalGiftIdeasCount(context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<Gift>(
            predicate: #Predicate { !$0.isGiven }
        )
        return (try? context.fetch(descriptor).count) ?? 0
    }
    
    // MARK: - Export/Import
    
    func exportData(context: ModelContext) -> Data? {
        let profilesDescriptor = FetchDescriptor<Profile>()
        let profiles = (try? context.fetch(profilesDescriptor)) ?? []
        
        let giftsDescriptor = FetchDescriptor<Gift>()
        let gifts = (try? context.fetch(giftsDescriptor)) ?? []
        
        let userProfileDescriptor = FetchDescriptor<UserProfile>()
        let userProfile = (try? context.fetch(userProfileDescriptor).first) ?? UserProfile()
        
        return DataExportImportManager.shared.exportData(
            profiles: profiles,
            gifts: gifts,
            userProfile: userProfile
        )
    }
    
    func exportToFile(context: ModelContext) -> URL? {
        let profilesDescriptor = FetchDescriptor<Profile>()
        let profiles = (try? context.fetch(profilesDescriptor)) ?? []
        
        let giftsDescriptor = FetchDescriptor<Gift>()
        let gifts = (try? context.fetch(giftsDescriptor)) ?? []
        
        let userProfileDescriptor = FetchDescriptor<UserProfile>()
        let userProfile = (try? context.fetch(userProfileDescriptor).first) ?? UserProfile()
        
        return DataExportImportManager.shared.exportToFile(
            profiles: profiles,
            gifts: gifts,
            userProfile: userProfile
        )
    }
    
    func importData(from data: Data) -> Bool {
        guard let imported = DataExportImportManager.shared.importData(from: data) else {
            return false
        }
        
        guard let context = modelContext else { return false }
        
        // Импортируем данные напрямую в SwiftData
        for profileCodable in imported.profiles {
            let profile = Profile(from: profileCodable)
            context.insert(profile)
        }
        
        for giftCodable in imported.gifts {
            let gift = Gift(from: giftCodable)
            context.insert(gift)
        }
        
        // Обновляем профиль пользователя
        let userProfileDescriptor = FetchDescriptor<UserProfile>()
        if let existing = try? context.fetch(userProfileDescriptor).first {
            existing.name = imported.userProfile.name
            existing.photoPath = imported.userProfile.photoPath
            existing.updatedAt = Date()
            existing.photoId = imported.userProfile.photoId
        } else {
            let userProfile = UserProfile(from: imported.userProfile)
            context.insert(userProfile)
        }
        
        do {
            try context.save()
            return true
        } catch {
            AppLogger.log("Error saving imported data: \(error.localizedDescription)", level: .error, category: "DataManager")
            ErrorManager.shared.showError(.dataSaveFailed(error.localizedDescription))
            return false
        }
    }
    
    func importFromFile(at url: URL) -> Bool {
        guard DataExportImportManager.shared.importFromFile(at: url) != nil else {
            return false
        }
        
        guard let data = try? Data(contentsOf: url) else {
            return false
        }
        
        return importData(from: data)
    }
}
