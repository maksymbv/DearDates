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
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Text(profile.name.prefix(1).uppercased())
                                    .font(.system(size: 50))
                                    .fontWeight(.semibold)
                            )
                    }
                    
                    Text(profile.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("\(formatDateShort(profile.nextBirthday)) исполнится \(profile.age + 1)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Заметки
                if !profile.notes.isEmpty {
                    Text(profile.notes)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                
                // Идеи подарков
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Идеи подарков")
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
                        Text("Нет идей подарков")
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
                        Text("История подарков")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(groupedGifts.keys.sorted(by: >), id: \.self) { year in
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\(String(year)) год")
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
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    private func formatDateShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

struct GiftRowView: View {
    @EnvironmentObject var dataManager: DataManager
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
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
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

