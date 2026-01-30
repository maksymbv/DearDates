//
//  SettingsUserProfileSection.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI
import SwiftData

struct SettingsUserProfileSection: View {
    var statsRefreshId: UUID = UUID()
    
    @Query private var allProfiles: [Profile]
    @Query private var allGifts: [Gift]
    
    @EnvironmentObject var settingsManager: SettingsManager
    
    private var giftIdeasCount: Int {
        allGifts.filter { !$0.isGiven }.count
    }
    
    private var givenGiftsCount: Int {
        allGifts.filter { $0.isGiven }.count
    }
    
    var body: some View {
        Section {
            HStack(spacing: 0) {
                // Статистика профилей
                VStack(spacing: 8) {
                    Image(systemName: "person.2.fill")
                        .font(.title3)
                        .foregroundColor(settingsManager.accentColor.color)
                        .accessibilityHidden(true)
                    
                    Text("\(allProfiles.count)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    
                    Text("label.profiles".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                }
                .frame(maxWidth: .infinity)
                
                
                // Статистика идей подарков
                VStack(spacing: 8) {
                    Image(systemName: "gift.fill")
                        .font(.title3)
                        .foregroundColor(settingsManager.accentColor.color)
                        .accessibilityHidden(true)
                    
                    Text("\(giftIdeasCount)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    
                    Text("label.gift_ideas".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                }
                .frame(maxWidth: .infinity)
                
                
                // Статистика подаренных подарков
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(settingsManager.accentColor.color)
                        .accessibilityHidden(true)
                    
                    Text("\(givenGiftsCount)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    
                    Text("label.given_gifts".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 12)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(String(format: "accessibility.user_profile_stats".localized, allProfiles.count, giftIdeasCount))
        }
        .id(statsRefreshId)
    }
}

