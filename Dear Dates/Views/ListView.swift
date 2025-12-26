//
//  ListView.swift
//  DearDates
//
//  Created on 2025
//

import SwiftUI

struct ListView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedGroupId: UUID? = nil
    @State private var showingAddGroup = false
    @State private var editingGroup: Group? = nil
    @State private var showingDeleteAlert: Group? = nil
    
    var filteredProfiles: [Profile] {
        let profiles = dataManager.getProfilesSortedByBirthday()
        if let selectedGroupId = selectedGroupId {
            return profiles.filter { $0.groupId == selectedGroupId }
        }
        return profiles
    }
    
    var sortedProfiles: [Profile] {
        dataManager.getProfilesSortedByBirthday()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Группы в хедере
                    if !sortedProfiles.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                // Кнопка "+" для создания группы
                                Button(action: { showingAddGroup = true }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(settingsManager.accentColor.color)
                                        .frame(width: 32, height: 32)
                                }
                                .padding(.horizontal, 4)
                                
                                // Кнопка "Все"
                            GroupFilterButton(
                                title: "button.all".localized,
                                    isSelected: selectedGroupId == nil,
                                    count: selectedGroupId == nil ? sortedProfiles.count : nil,
                                    accentColor: settingsManager.accentColor.color,
                                    onTap: {
                                        selectedGroupId = nil
                                    }
                                )
                                
                                // Кнопки групп
                                ForEach(dataManager.groups) { group in
                                    let count = sortedProfiles.filter { $0.groupId == group.id }.count
                                    GroupFilterButton(
                                        title: group.name,
                                        isSelected: selectedGroupId == group.id,
                                        count: selectedGroupId == group.id ? count : nil,
                                        accentColor: settingsManager.accentColor.color,
                                        onTap: {
                                            selectedGroupId = group.id
                                        },
                                        onLongPress: {
                                            editingGroup = group
                                        }
                                    )
                                }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                    }
                    .background(colorScheme == .light ? Color.appBackground : Color(.systemBackground))
                }
                    
                    // Список профилей
                    if filteredProfiles.isEmpty {
                        if sortedProfiles.isEmpty {
                            EmptyStateView()
                                .padding(.top, 20)
                        } else {
                            VStack(spacing: 20) {
                                Image(systemName: "person.3.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                
                            Text("message.no_profiles".localized)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("message.select_other_group".localized)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)
                            .padding(.bottom)
                        }
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredProfiles) { profile in
                                NavigationLink(destination: ProfileDetailView(profile: profile)) {
                                    ProfileRowView(profile: profile)
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical)
                        .animation(.easeInOut(duration: 0.3), value: selectedGroupId)
                    }
                }
            }
            .navigationTitle("navigation.list".localized)
            .background(colorScheme == .light ? Color.appBackground : Color(.systemBackground))
            .sheet(isPresented: $showingAddGroup) {
                NavigationView {
                    AddEditGroupView()
                }
            }
            .sheet(item: $editingGroup) { group in
                NavigationView {
                    GroupEditView(group: group) {
                        editingGroup = nil
                        if selectedGroupId == group.id {
                            selectedGroupId = nil
                        }
                    }
                }
            }
        }
    }
}

struct GroupFilterButton: View {
    let title: String
    let isSelected: Bool
    let count: Int?
    let accentColor: Color
    var onTap: () -> Void
    var onLongPress: (() -> Void)? = nil
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? accentColor : .primary)
            
            if let count = count, count > 0 {
                Text("\(count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? accentColor.opacity(0.8) : .secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(isSelected ? accentColor.opacity(0.1) : Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(colorScheme == .light ? Color.white : Color(.secondarySystemBackground))
        .foregroundColor(isSelected ? accentColor : .primary)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? accentColor : Color.clear, lineWidth: 2)
        )
        .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            if let onLongPress = onLongPress {
                onLongPress()
            }
        }
    }
}

struct ProfileRowView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.colorScheme) var colorScheme
    let profile: Profile
    
    var group: Group? {
        dataManager.getGroup(for: profile.groupId)
    }
    
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
                    .fill(Color.pastelColor(hue: profile.avatarColorHue).opacity(colorScheme == .dark ? 0.6 : 0.7))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(profile.name.prefix(1).uppercased())
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(profile.name)
                        .font(.headline)
                    
                    Spacer()
                    
                    if let group = group {
                        Text(group.name)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(settingsManager.accentColor.color.opacity(0.1))
                            .foregroundColor(settingsManager.accentColor.color)
                            .cornerRadius(8)
                    }
                }
                
                HStack(spacing: 8) {
                    Text(formatBirthday(profile.dateOfBirth))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if profile.daysUntilBirthday <= 30 {
                        Text(daysUntilBirthdayText(profile.daysUntilBirthday))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.tint)
                    }
                }
            }
        }
        .padding()
        .background(colorScheme == .light ? Color.white : Color(.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func formatBirthday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        formatter.locale = localizationManager.currentLanguage.locale
        return formatter.string(from: date)
    }
    
    private func daysUntilBirthdayText(_ days: Int) -> String {
        return localizationManager.daysUntilBirthdayText(days)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("empty.no_profiles_title".localized)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("empty.no_profiles_message".localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

