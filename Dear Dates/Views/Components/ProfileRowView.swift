//
//  ProfileRowView.swift
//  DearDates
//
//  Created on 2025
//

import SwiftUI

struct ProfileRowView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var imageManager: ImageManager
    @Environment(\.colorScheme) var colorScheme
    
    let profile: Profile
    
    private var avatarImage: UIImage? {
        guard let photoPath = profile.photoPath else { return nil }
        return imageManager.loadImage(from: photoPath)
    }
    
    private var formattedBirthday: String {
        DateFormatterHelper.formatBirthday(
            profile.dateOfBirth,
            locale: localizationManager.currentLanguage.locale
        )
    }
    
    private var daysUntilText: String? {
        guard profile.daysUntilBirthday <= 30 else { return nil }
        return localizationManager.daysUntilBirthdayText(profile.daysUntilBirthday)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            AvatarView(
                image: avatarImage,
                name: profile.name,
                avatarColorHue: profile.avatarColorHue,
                size: 60
            )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center) {
                    Text(profile.name)
                        .font(.headline)
                    
                    Spacer()
                    
                    if let daysText = daysUntilText {
                        Text(daysText)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(profile.daysUntilBirthday <= 3 ? settingsManager.accentColor.color : .secondary)
                    }
                }
                
                Text(formattedBirthday)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(colorScheme == .light ? Color.white : Color(.secondarySystemBackground))
        .cornerRadius(20)
        .overlay(alignment: .topTrailing) {
            if profile.isFavorite {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(settingsManager.accentColor.color)
                    .padding(.top, 14)
                    .padding(.trailing, 14)
            }
        }
        .shadow(
            color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.05),
            radius: 5,
            x: 0,
            y: 2
        )
    }
}

extension ProfileRowView: Equatable {
    static func == (lhs: ProfileRowView, rhs: ProfileRowView) -> Bool {
        lhs.profile.id == rhs.profile.id &&
        lhs.profile.name == rhs.profile.name &&
        lhs.profile.isFavorite == rhs.profile.isFavorite &&
        lhs.profile.daysUntilBirthday == rhs.profile.daysUntilBirthday &&
        lhs.profile.photoPath == rhs.profile.photoPath &&
        lhs.profile.dateOfBirth == rhs.profile.dateOfBirth
    }
}
