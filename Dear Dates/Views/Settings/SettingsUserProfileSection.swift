//
//  SettingsUserProfileSection.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI
import SwiftData

struct SettingsUserProfileSection: View {
    @Query private var userProfiles: [UserProfile]
    @Query private var allProfiles: [Profile]
    @Query private var allGifts: [Gift]
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var imageManager: ImageManager
    
    let onTap: () -> Void
    
    var body: some View {
        Section {
            Button(action: onTap) {
                HStack(spacing: 16) {
                    // Аватарка
                    let userProfile = userProfiles.first ?? UserProfile()
                    let userImage = userProfile.photoPath.flatMap { imageManager.loadImage(from: $0) }
                    
                    if let image = userImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .accessibilityHidden(true)
                    } else {
                        Circle()
                            .fill(settingsManager.accentColor.color.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(settingsManager.accentColor.color)
                            )
                            .accessibilityHidden(true)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        // Имя пользователя
                        Text(userProfile.name.isEmpty ? "navigation.user_profile".localized : userProfile.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                        
                        // Статистика
                        HStack(spacing: 20) {
                            HStack(spacing: 4) {
                                Image(systemName: "person.2.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .accessibilityHidden(true)
                                Text("\(allProfiles.count)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: "gift.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .accessibilityHidden(true)
                                Text("\(allGifts.filter { !$0.isGiven }.count)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .accessibilityHidden(true)
                }
                .padding(.vertical, 12)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("accessibility.user_profile_button".localized + ". " + String(format: "accessibility.user_profile_stats".localized, allProfiles.count, allGifts.filter { !$0.isGiven }.count))
        }
    }
}

