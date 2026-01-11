//
//  ProfileHeaderView.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI
import SwiftData

struct ProfileHeaderView: View {
    let profile: Profile
    let avatarImage: UIImage?
    let locale: Locale
    
    init(profile: Profile, avatarImage: UIImage?, locale: Locale) {
        self.profile = profile
        self.avatarImage = avatarImage
        self.locale = locale
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Круглое фото профиля (увеличенный размер)
            AvatarView(
                image: avatarImage,
                name: profile.name,
                avatarColorHue: profile.avatarColorHue,
                size: 200
            )
            
            // Имя под фото
            Text(profile.name)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("accessibility.profile_header".localized + " \(profile.name)")
    }
}

