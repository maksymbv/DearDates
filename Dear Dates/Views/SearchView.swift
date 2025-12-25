//
//  SearchView.swift
//  DearDates
//
//  Created on 2025
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.colorScheme) var colorScheme
    @State private var searchText = ""
    
    var filteredProfiles: [Profile] {
        if searchText.isEmpty {
            return []
        } else {
            return dataManager.profiles.filter { profile in
                profile.name.localizedCaseInsensitiveContains(searchText) ||
                profile.notes.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .light ? Color.appBackground : Color(.systemBackground))
                    .ignoresSafeArea()
                
                Group {
                    if filteredProfiles.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text(searchText.isEmpty ? "Начните поиск" : "Ничего не найдено")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            if !searchText.isEmpty {
                                Text("Попробуйте другой запрос")
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
            .navigationTitle("Поиск")
            .searchable(text: $searchText, prompt: "Поиск по имени или заметкам")
        }
    }
}

