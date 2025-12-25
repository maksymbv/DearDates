//
//  ListView.swift
//  DearDates
//
//  Created on 2025
//

import SwiftUI

struct ListView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.colorScheme) var colorScheme
    
    var sortedProfiles: [Profile] {
        dataManager.getProfilesSortedByBirthday()
    }
    
    var body: some View {
        NavigationView {
            Group {
                if sortedProfiles.isEmpty {
                    EmptyStateView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(sortedProfiles) { profile in
                                NavigationLink(destination: ProfileDetailView(profile: profile)) {
                                    ProfileRowView(profile: profile)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Список")
            .background(colorScheme == .light ? Color.appBackground : Color(.systemBackground))
        }
    }
}

struct ProfileRowView: View {
    let profile: Profile
    
    var body: some View {
        HStack(spacing: 12) {
            // Фото профиля
            if let photoPath = profile.photoPath,
               let image = ImageManager.shared.loadImage(from: photoPath) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(profile.name.prefix(1).uppercased())
                            .font(.title2)
                            .fontWeight(.semibold)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(profile.name)
                        .font(.headline)
                    
                    Spacer()
                    
                    if profile.daysUntilBirthday <= 30 {
                        Text(daysUntilBirthdayText(profile.daysUntilBirthday))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.tint)
                    }
                }
                
                Text(formatBirthday(profile.dateOfBirth))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func formatBirthday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    private func daysUntilBirthdayText(_ days: Int) -> String {
        if days == 0 {
            return "сегодня"
        } else if days == 1 {
            return "через 1 день"
        } else if days >= 2 && days <= 4 {
            return "через \(days) дня"
        } else {
            return "через \(days) дней"
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Нет профилей")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Добавьте первый профиль, чтобы начать отслеживать дни рождения")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

