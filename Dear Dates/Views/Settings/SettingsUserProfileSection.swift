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
                HStack(spacing: 12) {
                    // Аватарка
                    let userProfile = userProfiles.first ?? UserProfile()
                    let userImage = userProfile.photoPath.flatMap { imageManager.loadImage(from: $0) }
                    
                    let avatarSize = AdaptiveSize.size(baseSize: AppConstants.UI.baseAvatarSize)
                    
                    if let image = userImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: avatarSize, height: avatarSize)
                            .clipShape(Circle())
                            .accessibilityHidden(true)
                    } else {
                        Circle()
                            .fill(settingsManager.accentColor.color.opacity(0.2))
                            .frame(width: avatarSize, height: avatarSize)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: avatarSize * 0.5))
                                    .foregroundColor(settingsManager.accentColor.color)
                            )
                            .accessibilityHidden(true)
                    }
                    
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 4) {
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
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                                }
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "gift.fill")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .accessibilityHidden(true)
                                    Text("\(allGifts.filter { !$0.isGiven }.count)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                                }
                            }
                        }
                        
                        Spacer(minLength: 0)
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .accessibilityHidden(true)
                            .frame(maxHeight: .infinity, alignment: .center)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("accessibility.user_profile_button".localized + ". " + String(format: "accessibility.user_profile_stats".localized, allProfiles.count, allGifts.filter { !$0.isGiven }.count))
        }
    }
}

