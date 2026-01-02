//
//  AddEditProfileViewModel.swift
//  DearDates
//
//  Created on 2026
//

import Foundation
import SwiftData
import Photos
import UIKit
import Combine

enum ValidationError: Identifiable {
    case nameEmpty
    case nameTooLong
    case duplicateProfile
    
    var id: String {
        switch self {
        case .nameEmpty: return "nameEmpty"
        case .nameTooLong: return "nameTooLong"
        case .duplicateProfile: return "duplicateProfile"
        }
    }
    
    var localizedMessage: String {
        switch self {
        case .nameEmpty: return "validation.name_empty".localized
        case .nameTooLong: return "validation.name_too_long".localized
        case .duplicateProfile: return "validation.duplicate_profile".localized
        }
    }
}

@MainActor
class AddEditProfileViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var notes: String = ""
    @Published var notificationsEnabled: Bool = true
    @Published var selectedReminderDays: Set<Int> = [7, 1]
    @Published var selectedImage: UIImage?
    @Published var photoPath: String?
    @Published var validationErrors: [ValidationError] = []
    
    let availableReminderDays = [1, 3, 7, 14, 30]
    
    private let dataManager: DataManager
    private let notificationManager: NotificationManager
    private let imageManager: ImageManager
    private let errorManager: ErrorManager
    let profile: Profile?
    let allProfiles: [Profile]
    
    init(
        profile: Profile? = nil,
        allProfiles: [Profile],
        dataManager: DataManager? = nil,
        notificationManager: NotificationManager? = nil,
        imageManager: ImageManager? = nil,
        errorManager: ErrorManager? = nil
    ) {
        self.profile = profile
        self.allProfiles = allProfiles
        self.dataManager = dataManager ?? DataManager.shared
        self.notificationManager = notificationManager ?? NotificationManager.shared
        self.imageManager = imageManager ?? ImageManager.shared
        self.errorManager = errorManager ?? ErrorManager.shared

        loadProfile()
    }
    
    // MARK: - Loading
    
    private func loadProfile() {
        guard let profile = profile else { return }
        
        // Сохраняем значения свойств в локальные переменные, чтобы избежать ошибок SwiftData
        let profileName = profile.name
        let profileNotes = profile.notes
        let profileNotificationsEnabled = profile.notificationsEnabled
        let profileReminderDays = profile.reminderDays
        let profilePhotoPath = profile.photoPath
        
        name = profileName
        notes = profileNotes
        notificationsEnabled = profileNotificationsEnabled
        selectedReminderDays = Set(profileReminderDays)
        photoPath = profilePhotoPath
        
        if let photoPath = profilePhotoPath {
            selectedImage = imageManager.loadImage(from: photoPath)
        }
    }
    
    // MARK: - Validation
    
    func validate() -> Bool {
        validationErrors = []
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            validationErrors.append(.nameEmpty)
            return false
        }
        
        guard trimmedName.count <= 100 else {
            validationErrors.append(.nameTooLong)
            return false
        }
        
        if profile == nil {
            let existingProfile = allProfiles.first { existing in
                existing.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == trimmedName.lowercased()
            }
            
            if existingProfile != nil {
                validationErrors.append(.duplicateProfile)
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Save
    
    func saveProfile(context: ModelContext) -> UUID? {
        guard validate() else {
            if let firstError = validationErrors.first {
                errorManager.showError(.validationFailed(firstError.localizedMessage))
            }
            return nil
        }
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var savedPhotoPath = photoPath
        
        // Сохраняем новое фото если оно было выбрано
        if let image = selectedImage {
            let profileId = profile?.id ?? UUID()
            if let path = imageManager.saveImage(image, for: profileId) {
                savedPhotoPath = path
                
                // Удаляем старое фото если оно было
                if let oldPath = photoPath, oldPath != path {
                    imageManager.deleteImage(at: oldPath)
                }
            }
        }
        
        let reminderDaysArray = Array(selectedReminderDays).sorted()
        
        if let existingProfile = profile {
            // Обновляем существующий профиль
            existingProfile.name = trimmedName
            existingProfile.notes = notes
            existingProfile.notificationsEnabled = notificationsEnabled
            existingProfile.reminderDays = reminderDaysArray
            existingProfile.photoPath = savedPhotoPath
            
            dataManager.updateProfile(existingProfile, notificationManager: notificationManager, context: context)
            return existingProfile.id
        } else {
            // Создаем новый профиль
            let newProfile = Profile(
                name: trimmedName,
                photoPath: savedPhotoPath,
                notes: notes,
                notificationsEnabled: notificationsEnabled,
                reminderDays: reminderDaysArray
            )
            
            dataManager.addProfile(newProfile, context: context)
            notificationManager.scheduleNotifications(for: newProfile)
            return newProfile.id
        }
    }
    
    // MARK: - Delete
    
    func deleteProfile(context: ModelContext) {
        guard let profile = profile else { return }
        
        // Сохраняем данные профиля ДО удаления
        let photoPath = profile.photoPath
        
        // Удаляем фото асинхронно, чтобы не блокировать UI
        if let photoPath = photoPath {
            DispatchQueue.global(qos: .utility).async { [weak self] in
                self?.imageManager.deleteImage(at: photoPath)
            }
        }
        
        // Удаляем профиль (уведомления отменяются внутри deleteProfile)
        dataManager.deleteProfile(profile, notificationManager: notificationManager, context: context)
    }
    
    // MARK: - Photo Library
    
    func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            completion(true)
        case .denied, .restricted:
            errorManager.showError(.photoLibraryPermissionDenied)
            completion(false)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        completion(true)
                    } else {
                        self.errorManager.showError(.photoLibraryPermissionDenied)
                        completion(false)
                    }
                }
            }
        @unknown default:
            errorManager.showError(.photoLibraryPermissionDenied)
            completion(false)
        }
    }
    
}

