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
    
    var body: some View {
        VStack(spacing: 12) {
            AvatarView(
                image: avatarImage,
                name: profile.name,
                avatarColorHue: profile.avatarColorHue,
                size: 140
            )
            
            Text(profile.name)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("accessibility.profile_header".localized + " \(profile.name)")
    }
}

