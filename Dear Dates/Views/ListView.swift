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
    @Query private var allGifts: [Gift]
    
    // Профили, найденные по заметкам
    private var filteredProfilesByNotes: [Profile] {
        guard !searchText.isEmpty else { return [] }
        let searchLower = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return allProfiles.filter { profile in
            let notesTrimmed = profile.notes.trimmingCharacters(in: .whitespacesAndNewlines)
            return !notesTrimmed.isEmpty && notesTrimmed.lowercased().contains(searchLower)
        }
    }
    
    // Профили, найденные только по имени (не по заметкам)
    private var filteredProfilesByName: [Profile] {
        guard !searchText.isEmpty else { return [] }
        let searchLower = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let notesProfileIds = Set(filteredProfilesByNotes.map { $0.id })
        return allProfiles.filter { profile in
            profile.name.lowercased().contains(searchLower) && !notesProfileIds.contains(profile.id)
        }
    }
    
    // Идеи подарков
    private var filteredGiftIdeas: [(gift: Gift, profile: Profile)] {
        guard !searchText.isEmpty else { return [] }
        let searchLower = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
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
    
    private var hasSearchResults: Bool {
        !searchText.isEmpty && (!filteredProfilesByName.isEmpty || !filteredProfilesByNotes.isEmpty || !filteredGiftIdeas.isEmpty)
    }
    
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @State private var showingAddProfile = false
    @State private var showingSettings = false
    @State private var selectedProfileId: UUID?
    @State private var searchText = ""
    @State private var isSearchPresented = false
    @FocusState private var isSearchFieldFocused: Bool
    
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
            // Сначала прикрепленные профили
            if profile1.isPinned != profile2.isPinned {
                return profile1.isPinned
            }
            
            // Если оба закреплены, сортируем по updatedAt (самые свежие сверху)
            if profile1.isPinned && profile2.isPinned {
                return profile1.updatedAt > profile2.updatedAt
            }
            
            // Для незакрепленных сортируем по дате события
            let event1 = getNextEvent(for: profile1)
            let event2 = getNextEvent(for: profile2)
            let days1 = event1?.daysUntil ?? Int.max
            let days2 = event2?.daysUntil ?? Int.max
            return days1 < days2
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Фон для всего экрана
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if hasSearchResults {
                    // Результаты поиска в трех секциях
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            // Профили, найденные по имени
                            if !filteredProfilesByName.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("label.profiles".localized)
                                        .font(.headline)
                                        .padding(.horizontal)
                                    
                                    ForEach(filteredProfilesByName, id: \.id) { profile in
                                        NavigationLink(destination: ProfileDetailView(profileId: profile.id)) {
                                            ProfileRowView(
                                                profile: profile,
                                                locale: localizationManager.currentLanguage.locale,
                                                searchText: searchText
                                            )
                                            .id("\(profile.id.uuidString)_\(searchText)")
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            
                            // Профили, найденные по заметкам
                            if !filteredProfilesByNotes.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("label.notes".localized)
                                        .font(.headline)
                                        .padding(.horizontal)
                                    
                                    ForEach(filteredProfilesByNotes, id: \.id) { profile in
                                        NavigationLink(destination: ProfileDetailView(profileId: profile.id)) {
                                            ProfileNotesSearchRow(
                                                profile: profile,
                                                searchText: searchText
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
                                            GiftIdeaSearchRow(
                                                gift: item.gift,
                                                profile: item.profile,
                                                searchText: searchText
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                } else if sortedProfiles.isEmpty {
                    // Пустое состояние - по центру экрана
                    EmptyStateView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Стандартный список профилей
                    List {
                        ForEach(sortedProfiles, id: \.id) { profile in
                            profileRow(for: profile)
                                .id("\(profile.id.uuidString)-\(profile.isPinned)")
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(action: {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                                            DataManager.shared.togglePin(profile, context: modelContext)
                                        }
                                    }) {
                                        Image(systemName: profile.isPinned ? "pin.slash.fill" : "pin.fill")
                                    }
                                    .tint(settingsManager.accentColor.color)
                                    .accessibilityLabel(profile.isPinned ? "accessibility.unpin_profile".localized : "accessibility.pin_profile".localized)
                                }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showingSettings) {
                SettingsView()
            }
            .navigationDestination(isPresented: Binding(
                get: { selectedProfileId != nil },
                set: { if !$0 { selectedProfileId = nil } }
            )) {
                if let profileId = selectedProfileId {
                    ProfileDetailView(profileId: profileId)
                }
            }
            .toolbar {
                if !isSearchPresented {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gearshape")
                        }
                        .accessibilityLabel("navigation.settings".localized)
                    }
                }
                
                ToolbarItemGroup(placement: isSearchPresented ? .principal : .navigationBarTrailing) {
                    if isSearchPresented {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            TextField("message.search_prompt".localized, text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                                .frame(maxWidth: .infinity)
                                .focused($isSearchFieldFocused)
                                .onSubmit {
                                    withAnimation {
                                        isSearchPresented = false
                                    }
                                }
                        }
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    } else {
                        Button(action: {
                            withAnimation {
                                isSearchPresented = true
                            }
                            // Устанавливаем фокус после небольшой задержки для анимации
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isSearchFieldFocused = true
                            }
                        }) {
                            Image(systemName: "magnifyingglass")
                        }
                        .accessibilityLabel("navigation.search".localized)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isSearchPresented {
                        Button(action: {
                            searchText = ""
                            withAnimation {
                                isSearchPresented = false
                            }
                        }) {
                            Image(systemName: "xmark")
                        }
                        .accessibilityLabel("accessibility.close".localized)
                    } else {
                        Button(action: {
                            showingAddProfile = true
                        }) {
                            Image(systemName: "plus")
                        }
                        .tint(settingsManager.accentColor.color)
                        .accessibilityLabel("accessibility.add_profile".localized)
                    }
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
                locale: localizationManager.currentLanguage.locale,
                searchText: searchText
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
}
