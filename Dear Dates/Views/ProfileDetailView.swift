//
//  ProfileDetailView.swift
//  DearDates
//
//  Created on 2025
//

import SwiftUI

struct ProfileDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var imageManager: ImageManager
    @Environment(\.colorScheme) var colorScheme
    
    let profileId: UUID
    
    private var profile: Profile? {
        dataManager.profiles.first { $0.id == profileId }
    }
    
    @State private var showingEditProfile = false
    @State private var showingAddGift = false
    @State private var showingEditGift: Gift? = nil
    @State private var refreshTrigger = UUID()
    
    var body: some View {
        Group {
            if let profile = profile {
                ScrollView {
                    VStack(spacing: 20) {
                        headerInfo(profile: profile)
                        notesSection(profile: profile)
                        giftIdeasSection(profileId: profile.id)
                        giftHistorySection(profileId: profile.id)
                    }
                    .padding(.vertical)
                }
                .appBackground(colorScheme: colorScheme)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: { toggleFavorite(profile: profile) }) {
                            Image(systemName: profile.isFavorite ? "star.fill" : "star")
                                .foregroundColor(profile.isFavorite ? settingsManager.accentColor.color : .primary)
                        }
                        
                        Button(action: { showingEditProfile = true }) {
                            Image(systemName: "pencil")
                        }
                    }
                }
                .sheet(isPresented: $showingEditProfile) {
                    AddEditProfileView(profile: profile)
                }
                .sheet(isPresented: $showingAddGift) {
                    AddEditGiftView(profileId: profile.id)
                }
                .sheet(item: $showingEditGift) { gift in
                    AddEditGiftView(profileId: profile.id, gift: gift)
                }
                .onChange(of: showingEditGift) { oldValue, newValue in
                    if newValue == nil {
                        refreshTrigger = UUID()
                    }
                }
                .onChange(of: showingAddGift) { oldValue, newValue in
                    if !newValue {
                        refreshTrigger = UUID()
                    }
                }
                .onReceive(dataManager.$gifts) { _ in
                    refreshTrigger = UUID()
                }
            } else {
                Text("Профиль не найден")
                    .foregroundColor(.secondary)
            }
        }
        .onReceive(dataManager.$profiles) { _ in
            refreshTrigger = UUID()
        }
    }
    
    @ViewBuilder
    private func headerInfo(profile: Profile) -> some View {
        VStack(spacing: 12) {
            AvatarView(
                image: profile.photoPath.flatMap { imageManager.loadImage(from: $0) },
                name: profile.name,
                avatarColorHue: profile.avatarColorHue,
                size: 120
            )
            
            Text(profile.name)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            
            Text("\(DateFormatterHelper.formatBirthday(profile.nextBirthday, locale: localizationManager.currentLanguage.locale)) \("message.will_turn".localized) \(profile.age + 1)")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    @ViewBuilder
    private func notesSection(profile: Profile) -> some View {
        if !profile.notes.isEmpty {
            Text(profile.notes)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(colorScheme == .dark ? Color(.systemGray6) : Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func giftIdeasSection(profileId: UUID) -> some View {
        let giftIdeas = dataManager.getGiftIdeas(for: profileId)
        
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("label.gift_ideas".localized)
                    .font(.headline)
                    .padding(.horizontal)
                
                Spacer()
                
                Button(action: { showingAddGift = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                }
                .padding(.horizontal)
            }
            
            if giftIdeas.isEmpty {
                Text("message.no_gift_ideas".localized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                ForEach(giftIdeas, id: \.id) { gift in
                    GiftRowView(gift: gift, isIdea: true, onEdit: {
                        showingEditGift = gift
                    })
                }
            }
        }
        .id(refreshTrigger)
    }
    
    @ViewBuilder
    private func giftHistorySection(profileId: UUID) -> some View {
        let givenGifts = dataManager.getGivenGifts(for: profileId)
        let groupedGifts = Gift.groupedByYear(givenGifts)
        
        if !groupedGifts.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("label.gift_history".localized)
                    .font(.headline)
                    .padding(.horizontal)
                
                ForEach(groupedGifts.keys.sorted(by: >), id: \.self) { year in
                    yearGiftsSection(year: year, gifts: groupedGifts[year] ?? [])
                }
            }
            .id(refreshTrigger)
        }
    }
    
    @ViewBuilder
    private func yearGiftsSection(year: Int, gifts: [Gift]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(String(year))")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ForEach(gifts, id: \.id) { gift in
                GiftRowView(gift: gift, isIdea: false, onEdit: {
                    showingEditGift = gift
                })
            }
        }
    }
    
    private func toggleFavorite(profile: Profile) {
        var updatedProfile = profile
        updatedProfile.isFavorite.toggle()
        updatedProfile.updatedAt = Date()
        dataManager.updateProfile(updatedProfile, notificationManager: notificationManager)
    }
}
