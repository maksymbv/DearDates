//
//  SearchView.swift
//  DearDates
//
//  Created on 2025
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.colorScheme) var colorScheme
    @State private var searchText = ""
    
    var filteredProfiles: [Profile] {
        if searchText.isEmpty {
            return []
        } else {
            let searchLower = searchText.lowercased()
            return dataManager.profiles.filter { profile in
                profile.name.lowercased().contains(searchLower) ||
                (!profile.notes.isEmpty && profile.notes.lowercased().contains(searchLower))
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .light ? Color.appBackground : Color(.systemBackground))
                    .ignoresSafeArea()
                
                SwiftUI.Group {
                    if filteredProfiles.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
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
                            LazyVStack(spacing: 12) {
                                ForEach(filteredProfiles) { profile in
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
            }
            .navigationTitle("navigation.search".localized)
            .searchable(text: $searchText, prompt: "message.search_prompt".localized)
        }
    }
}

