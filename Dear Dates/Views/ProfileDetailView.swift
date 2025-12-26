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
    @Environment(\.colorScheme) var colorScheme
    @State var profile: Profile
    @State private var showingEditProfile = false
    @State private var showingAddGift = false
    @State private var showingEditGift: Gift? = nil
    
    var gifts: [Gift] {
        dataManager.getGifts(for: profile.id)
    }
    
    var giftIdeas: [Gift] {
        dataManager.getGiftIdeas(for: profile.id)
    }
    
    var givenGifts: [Gift] {
        dataManager.getGivenGifts(for: profile.id)
    }
    
    var groupedGifts: [Int: [Gift]] {
        Gift.groupedByYear(givenGifts)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Фото и основная информация
                VStack(spacing: 12) {
                    if let photoPath = profile.photoPath,
                       let image = ImageManager.shared.loadImage(from: photoPath) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.pastelColor(hue: profile.avatarColorHue).opacity(colorScheme == .dark ? 0.6 : 0.7))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Text(profile.name.prefix(1).uppercased())
                                    .font(.system(size: 50))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            )
                    }
                    
                    Text(profile.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    
                    Text("\(formatDateShort(profile.nextBirthday)) \("message.will_turn".localized) \(profile.age + 1)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    if let group = dataManager.getGroup(for: profile.groupId) {
                        Text(group.name)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(settingsManager.accentColor.color.opacity(0.1))
                            .foregroundColor(settingsManager.accentColor.color)
                            .cornerRadius(12)
                    }
                }
                .padding()
                
                // Заметки
                if !profile.notes.isEmpty {
                    Text(profile.notes)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(colorScheme == .dark ? Color(.systemGray6) : Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                
                // Идеи подарков
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
                        ForEach(giftIdeas) { gift in
                            GiftRowView(gift: gift, isIdea: true, onEdit: {
                                showingEditGift = gift
                            })
                        }
                    }
                }
                
                // История подарков
                if !groupedGifts.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("label.gift_history".localized)
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(groupedGifts.keys.sorted(by: >), id: \.self) { year in
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\(String(year)) \("label.year".localized)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                                ForEach(groupedGifts[year] ?? []) { gift in
                                    GiftRowView(gift: gift, isIdea: false, onEdit: {
                                        showingEditGift = gift
                                    })
                                }
                            }
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .background(colorScheme == .light ? Color.appBackground : Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingEditProfile = true }) {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            AddEditProfileView(profile: profile)
        }
        .onChange(of: showingEditProfile) { _, newValue in
            if !newValue {
                // Обновляем профиль после закрытия редактирования
                if let updatedProfile = dataManager.profiles.first(where: { $0.id == profile.id }) {
                    profile = updatedProfile
                }
            }
        }
        .sheet(isPresented: $showingAddGift) {
            AddEditGiftView(profileId: profile.id)
        }
        .sheet(item: $showingEditGift) { gift in
            AddEditGiftView(profileId: profile.id, gift: gift)
        }
        .onAppear {
            // Обновляем профиль из dataManager
            if let updatedProfile = dataManager.profiles.first(where: { $0.id == profile.id }) {
                profile = updatedProfile
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = localizationManager.currentLanguage.locale
        return formatter.string(from: date)
    }
    
    private func formatDateShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        formatter.locale = localizationManager.currentLanguage.locale
        return formatter.string(from: date)
    }
}

struct GiftRowView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.colorScheme) var colorScheme
    let gift: Gift
    let isIdea: Bool
    var onEdit: (() -> Void)? = nil
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(gift.title)
                    .font(.body)
                    .fontWeight(.medium)
                
                if !gift.description.isEmpty {
                    Text(gift.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if isIdea {
                Button(action: { markAsGiven() }) {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                        .font(.title3)
                }
            }
        }
        .padding()
        .background(colorScheme == .light ? Color.white : Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
        .contentShape(Rectangle())
        .onTapGesture {
            if let onEdit = onEdit {
                onEdit()
            }
        }
    }
    
    private func markAsGiven() {
        var updatedGift = gift
        updatedGift.isGiven = true
        updatedGift.givenYear = Calendar.current.component(.year, from: Date())
        dataManager.updateGift(updatedGift)
    }
}

