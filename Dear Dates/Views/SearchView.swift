//
//  SearchView.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @Query private var allProfiles: [Profile]
    @Query private var allGifts: [Gift]
    
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.colorScheme) var colorScheme
    @State private var searchText = ""
    
    var filteredProfiles: [Profile] {
        if searchText.isEmpty {
            return []
        } else {
            let searchLower = searchText.lowercased()
            return allProfiles.filter { profile in
                profile.name.lowercased().contains(searchLower) ||
                (!profile.notes.isEmpty && profile.notes.lowercased().contains(searchLower))
            }
        }
    }
    
    var filteredGiftIdeas: [(gift: Gift, profile: Profile)] {
        if searchText.isEmpty {
            return []
        } else {
            let searchLower = searchText.lowercased()
            var results: [(gift: Gift, profile: Profile)] = []
            
            for gift in allGifts where !gift.isGiven {
                if gift.title.lowercased().contains(searchLower) ||
                   (!gift.notes.isEmpty && gift.notes.lowercased().contains(searchLower)) {
                    if let profile = allProfiles.first(where: { $0.id == gift.profileId }) {
                        results.append((gift: gift, profile: profile))
            }
        }
            }
            
            return results
        }
    }
    
    var hasResults: Bool {
        !filteredProfiles.isEmpty || !filteredGiftIdeas.isEmpty
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.clear
                    .appBackground(colorScheme: colorScheme)
                    .ignoresSafeArea()
                
                SwiftUI.Group {
                    if !hasResults {
                        VStack(spacing: 20) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundColor(.accentColor)
                            
                            Text(searchText.isEmpty ? "message.start_search".localized : "message.nothing_found".localized)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            if !searchText.isEmpty {
                                Text("message.try_another_query".localized)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                // Профили
                                if !filteredProfiles.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("label.profiles".localized)
                                            .font(.headline)
                                            .padding(.horizontal)
                                        
                                ForEach(filteredProfiles) { profile in
                                    NavigationLink(destination: ProfileDetailView(profileId: profile.id)) {
                                        ProfileRowView(
                                            profile: profile,
                                            accentColor: settingsManager.accentColor.color,
                                            locale: localizationManager.currentLanguage.locale
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                            .padding(.horizontal)
                                }
                            }
                                }
                                
                                // Идеи подарков
                                if !filteredGiftIdeas.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("label.gift_ideas".localized)
                                            .font(.headline)
                                            .padding(.horizontal)
                                        
                                        ForEach(filteredGiftIdeas, id: \.gift.id) { item in
                                            NavigationLink(destination: ProfileDetailView(profileId: item.profile.id)) {
                                                GiftIdeaSearchRow(gift: item.gift, profile: item.profile)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                }
            }
            .navigationTitle("navigation.search".localized)
            .searchable(text: $searchText, prompt: "message.search_prompt".localized)
        }
    }
}

