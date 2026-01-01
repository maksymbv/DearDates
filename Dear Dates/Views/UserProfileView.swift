//
//  UserProfileView.swift
//  DearDates
//
//  Created on 2025
//

import SwiftUI

struct UserProfileView: View {
    @Environment(\.dismiss) var dismiss
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
        dataManager.getTotalProfilesCount()
    }
    
    private var totalGiftIdeasCount: Int {
        dataManager.getTotalGiftIdeasCount()
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
                            
                            Button(action: { showingImagePicker = true }) {
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
                            
                            Spacer()
                        }
                        .padding(.vertical)
                    }
                    
                    Section(header: Text("section.main_info".localized)) {
                        TextField("label.name".localized, text: $name)
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
                    Button("button.cancel".localized) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("button.save".localized) {
                        saveProfile()
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
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
        let profile = dataManager.getUserProfile()
        name = profile.name
        photoPath = profile.photoPath
        
        if let photoPath = photoPath {
            selectedImage = imageManager.loadImage(from: photoPath)
        }
    }
    
    private func saveProfile() {
        var newPhotoPath = photoPath
        let currentProfile = dataManager.getUserProfile()
        var photoId = currentProfile.photoId
        
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
        
        let userProfile = UserProfile(
            name: name.trimmingCharacters(in: .whitespaces),
            photoPath: newPhotoPath,
            updatedAt: Date(),
            photoId: photoId
        )
        
        dataManager.updateUserProfile(userProfile)
    }
}

