//
//  UserProfileView.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI
import SwiftData
import Photos

struct UserProfileView: View {
    @Query private var allProfiles: [Profile]
    @Query private var allGifts: [Gift]
    @Query private var userProfiles: [UserProfile]
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var imageManager: ImageManager
    
    @State private var name: String = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var photoPath: String?
    
    private var totalProfilesCount: Int {
        allProfiles.count
    }
    
    private var totalGiftIdeasCount: Int {
        allGifts.filter { !$0.isGiven }.count
    }
    
    private var currentUserProfile: UserProfile? {
        userProfiles.first
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.clear
                    .appBackground(colorScheme: colorScheme)
                    .ignoresSafeArea()
                
                Form {
                    Section(header: Text("label.photo".localized)) {
                        HStack {
                            Spacer()
                            
                            Button(action: { checkPhotoLibraryPermission() }) {
                                if let image = selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                } else if let photoPath = photoPath, let image = imageManager.loadImage(from: photoPath) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                } else {
                                    VStack {
                                        Image(systemName: "person.circle.fill")
                                            .font(.system(size: 60))
                                            .foregroundColor(settingsManager.accentColor.color)
                                        Text("label.add_photo".localized)
                                            .font(.caption)
                                            .foregroundColor(settingsManager.accentColor.color)
                                    }
                                    .frame(width: 120, height: 120)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .accessibilityLabel("accessibility.add_photo_button".localized)
                            .accessibilityHint("accessibility.add_photo_button_hint".localized)
                            
                            Spacer()
                        }
                        .padding(.vertical)
                    }
                    
                    Section(header: Text("section.main_info".localized)) {
                        TextField("label.user_profile_name_placeholder".localized, text: $name)
                    }
                    
                    Section(header: Text("label.statistics".localized)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(totalProfilesCount)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(settingsManager.accentColor.color)
                                Text("label.profiles".localized)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("\(totalGiftIdeasCount)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(settingsManager.accentColor.color)
                                Text("label.gift_ideas".localized)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("navigation.user_profile".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("button.cancel".localized)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        saveProfile()
                        dismiss()
                    }) {
                        Image(systemName: "checkmark")
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityLabel("button.save".localized)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .onAppear {
                loadProfile()
            }
        }
    }
    
    private func loadProfile() {
        if let profile = currentUserProfile {
            name = profile.name
            photoPath = profile.photoPath
            
            if let photoPath = photoPath {
                selectedImage = imageManager.loadImage(from: photoPath)
            }
        }
    }
    
    private func saveProfile() {
        var newPhotoPath = photoPath
        var photoId = currentUserProfile?.photoId
        
        // Генерируем новый photoId если его нет
        if photoId == nil {
            photoId = UUID()
        }
        
        // Сохраняем новое фото если оно было выбрано
        if let image = selectedImage, let userId = photoId {
            if let savedPath = imageManager.saveImage(image, for: userId) {
                // Удаляем старое фото если оно было
                if let oldPath = photoPath, oldPath != savedPath {
                    imageManager.deleteImage(at: oldPath)
                }
                newPhotoPath = savedPath
            }
        }
        
        let userProfile: UserProfile
        if let existing = currentUserProfile {
            existing.name = name.trimmingCharacters(in: .whitespaces)
            existing.photoPath = newPhotoPath
            existing.updatedAt = Date()
            existing.photoId = photoId
            userProfile = existing
        } else {
            userProfile = UserProfile(
                name: name.trimmingCharacters(in: .whitespaces),
                photoPath: newPhotoPath,
                updatedAt: Date(),
                photoId: photoId
            )
            modelContext.insert(userProfile)
        }
        
        dataManager.updateUserProfile(userProfile, context: modelContext)
    }
    
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            // Разрешение есть, можно открыть picker
            showingImagePicker = true
        case .denied, .restricted:
            // Доступ запрещен, показываем ошибку
            ErrorManager.shared.showError(.photoLibraryPermissionDenied)
        case .notDetermined:
            // Запрашиваем разрешение
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self.showingImagePicker = true
                    } else {
                        ErrorManager.shared.showError(.photoLibraryPermissionDenied)
                    }
                }
            }
        @unknown default:
            ErrorManager.shared.showError(.photoLibraryPermissionDenied)
        }
    }
}

