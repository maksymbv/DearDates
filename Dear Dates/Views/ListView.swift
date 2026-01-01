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
    @State private var prioritizeFavorites = false
    @State private var showingAddProfile = false
    @State private var refreshID = UUID()
    
    private var sortedProfiles: [Profile] {
        dataManager.getProfilesSortedByBirthday()
    }
    
    private var hasFavorites: Bool {
        dataManager.profiles.contains { $0.isFavorite }
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
        NavigationView {
            ZStack {
                // Фон для всего экрана
                (colorScheme == .light ? Color.appBackground : Color(.systemBackground))
                    .ignoresSafeArea()
                
                if filteredProfiles.isEmpty {
                    // Пустое состояние - по центру экрана
                    EmptyStateView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Список профилей
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredProfiles, id: \.id) { profile in
                                profileRow(for: profile)
                                    .id("\(profile.id)-\(profile.updatedAt.timeIntervalSince1970)")
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical)
                        .animation(.easeInOut(duration: AppConstants.UI.animationDuration), value: prioritizeFavorites)
                    }
                    .id(refreshID)
                }
            }
            .navigationTitle("navigation.events".localized)
            .appBackground(colorScheme: colorScheme)
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
    }
    
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddProfile = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddProfile) {
                AddEditProfileView()
            }
            .onReceive(dataManager.$profiles) { _ in
                // Обновляем view при изменении профилей
                refreshID = UUID()
            }
        }
    }
    
    @ViewBuilder
    private func profileRow(for profile: Profile) -> some View {
        NavigationLink(destination: ProfileDetailView(profileId: profile.id)) {
            ProfileRowView(profile: profile)
                .transition(.opacity.combined(with: .move(edge: .top)))
        }
        .buttonStyle(PlainButtonStyle())
        }
    }


