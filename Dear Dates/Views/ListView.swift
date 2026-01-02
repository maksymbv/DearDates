//
//  ListView.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI
import SwiftData

struct ListView: View {
    @Query(sort: [SortDescriptor<Profile>(\.createdAt)])
    private var allProfiles: [Profile]
    
    @Query private var allEvents: [CustomEvent]
    
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.colorScheme) var colorScheme
    @State private var prioritizeFavorites = false
    @State private var showingAddProfile = false
    @State private var selectedProfileId: UUID?
    
    // Получаем следующее событие для профиля
    private func getNextEvent(for profile: Profile) -> (name: String, date: Date, daysUntil: Int)? {
        // Добавляем только пользовательские события
        let profileEvents = allEvents.filter { $0.profileId == profile.id }
        
        // Сортируем по дате и возвращаем ближайшее
        return profileEvents
            .map { event in
                (name: event.name, date: event.nextDate, daysUntil: event.daysUntil)
            }
            .sorted { $0.date < $1.date }
            .first
    }
    
    private var sortedProfiles: [Profile] {
        allProfiles.sorted { profile1, profile2 in
            let event1 = getNextEvent(for: profile1)
            let event2 = getNextEvent(for: profile2)
            let days1 = event1?.daysUntil ?? Int.max
            let days2 = event2?.daysUntil ?? Int.max
            return days1 < days2
        }
    }
    
    private var hasFavorites: Bool {
        allProfiles.contains { $0.isFavorite }
    }
    
    private var filteredProfiles: [Profile] {
        let profiles = sortedProfiles
        
        guard prioritizeFavorites && hasFavorites else {
            return profiles
        }
        
        var favorites: [Profile] = []
        var nonFavorites: [Profile] = []
        
        for profile in profiles {
            if profile.isFavorite {
                favorites.append(profile)
            } else {
                nonFavorites.append(profile)
            }
        }
        
        return favorites + nonFavorites
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Фон для всего экрана
                (colorScheme == .light ? Color.appBackground : Color(.systemBackground))
                    .ignoresSafeArea()
                
                if filteredProfiles.isEmpty {
                    // Пустое состояние - по центру экрана
                    EmptyStateView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Стандартный список профилей
                    List {
                        ForEach(filteredProfiles) { profile in
                            profileRow(for: profile)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .animation(.easeInOut(duration: AppConstants.UI.animationDuration), value: prioritizeFavorites)
                }
            }
            .navigationTitle("navigation.people".localized)
            .navigationDestination(isPresented: Binding(
                get: { selectedProfileId != nil },
                set: { if !$0 { selectedProfileId = nil } }
            )) {
                if let profileId = selectedProfileId {
                    ProfileDetailView(profileId: profileId)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { 
                        if hasFavorites {
                            withAnimation(.easeInOut(duration: AppConstants.UI.animationDuration)) {
                                prioritizeFavorites.toggle()
                            }
                        }
                    }) {
                        Image(systemName: (prioritizeFavorites && hasFavorites) ? "star.fill" : "star")
                            .foregroundColor((prioritizeFavorites && hasFavorites) ? settingsManager.accentColor.color : .primary)
                    }
                    .animation(.easeInOut(duration: AppConstants.UI.animationDuration), value: prioritizeFavorites)
                    .accessibilityLabel((prioritizeFavorites && hasFavorites) ? "accessibility.show_all_profiles".localized : "accessibility.show_favorites".localized)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddProfile = true
                    }) {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("accessibility.add_profile".localized)
                }
            }
            .fullScreenCover(isPresented: $showingAddProfile) {
                AddEditProfileView { profileId in
                    // Переходим к созданному профилю
                    selectedProfileId = profileId
                }
            }
        }
    }

    @ViewBuilder
    private func profileRow(for profile: Profile) -> some View {
        Button(action: {
            selectedProfileId = profile.id
        }) {
            ProfileRowView(
                profile: profile,
                accentColor: settingsManager.accentColor.color,
                locale: localizationManager.currentLanguage.locale
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
}
