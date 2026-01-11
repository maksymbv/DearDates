//
//  ProfileDetailView.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI
import SwiftData
import UIKit

struct ProfileDetailView: View {
    @Query private var allProfiles: [Profile]
    @Query private var allGifts: [Gift]
    @Query private var allEvents: [CustomEvent]
    
    @StateObject private var viewModel = ProfileDetailViewModel()
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var imageManager: ImageManager
    
    let profileId: UUID
    
    private var profile: Profile? {
        allProfiles.first { $0.id == profileId }
    }
    
    private var profileGifts: [Gift] {
        allGifts.filter { $0.profileId == profileId }
    }
    
    private var giftIdeas: [Gift] {
        profileGifts.filter { !$0.isGiven }
    }
    
    private var givenGifts: [Gift] {
        profileGifts.filter { $0.isGiven }
    }
    
    var body: some View {
        Group {
            if let profile = profile {
                List {
                    ProfileHeaderView(
                        profile: profile,
                        avatarImage: profile.photoPath.flatMap { imageManager.loadImage(from: $0) },
                        locale: localizationManager.currentLanguage.locale
                    )
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                    // Секция событий
                    let profileEvents = allEvents.filter { $0.profileId == profile.id }.sorted { event1, event2 in
                        // События сегодня идут первыми
                        if event1.isToday && !event2.isToday { return true }
                        if !event1.isToday && event2.isToday { return false }
                        // Остальные сортируются по дате
                        return event1.nextDate < event2.nextDate
                    }
                    Section {
                        if !profileEvents.isEmpty {
                            ForEach(profileEvents, id: \.id) { event in
                                Button(action: {
                                    viewModel.showingEditEvent = event
                                }) {
                                    HStack {
                                        HStack(spacing: 4) {
                                            Text(event.name)
                                                .font(.body)
                                                .fontWeight(.medium)
                                                .foregroundColor(.primary)
                                                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                                            Text("·")
                                                .font(.body)
                                                .foregroundColor(.primary)
                                                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                                            Text(DateFormatterHelper.formatEventDate(event.nextDate, locale: localizationManager.currentLanguage.locale))
                                                .font(.body)
                                                .foregroundColor(.primary)
                                                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        } else {
                            Text("message.add_first_event".localized)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } header: {
                        HStack {
                            Text("section.events".localized)
                            Spacer()
                            Button(action: { viewModel.showingAddEvent = true }) {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(settingsManager.accentColor.color)
                            }
                        }
                    }
                    
                    if !profile.notes.isEmpty {
                        Section {
                            ProfileNotesSection(notes: profile.notes)
                        } header: {
                            Text("label.notes".localized)
                        }
                    }
                    
                    Section {
                        GiftIdeasSection(
                            giftIdeas: giftIdeas,
                            onAddGift: { viewModel.showingAddGift = true },
                            onEditGift: { viewModel.showingEditGift = $0 }
                        )
                    } header: {
                        HStack {
                            Text("label.gift_ideas".localized)
                            Spacer()
                            Button(action: { viewModel.showingAddGift = true }) {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(settingsManager.accentColor.color)
                            }
                        }
                    }
                    
                    Section {
                        GiftHistorySection(
                            givenGifts: givenGifts,
                            onEditGift: { viewModel.showingEditGift = $0 }
                        )
                    }
                }
                .listStyle(.insetGrouped)
                .contentMargins(.top, 0, for: .scrollContent)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: { viewModel.toggleFavorite(profile: profile, context: modelContext) }) {
                            Image(systemName: profile.isFavorite ? "star.fill" : "star")
                                .foregroundColor(profile.isFavorite ? settingsManager.accentColor.color : .primary)
                        }
                        .accessibilityLabel(profile.isFavorite ? "accessibility.remove_favorite".localized : "accessibility.add_favorite".localized)
                        
                        Button(action: { viewModel.showingEditProfile = true }) {
                            Image(systemName: "pencil")
                        }
                        .accessibilityLabel("accessibility.edit_profile".localized)
                    }
                }
                .fullScreenCover(isPresented: $viewModel.showingEditProfile) {
                    AddEditProfileView(profile: profile)
                }
                .fullScreenCover(isPresented: $viewModel.showingAddGift) {
                    AddEditGiftView(profileId: profile.id)
                }
                .fullScreenCover(item: $viewModel.showingEditGift) { gift in
                    AddEditGiftView(profileId: profile.id, gift: gift)
                }
                .fullScreenCover(isPresented: $viewModel.showingAddEvent) {
                    AddEditEventView(profileId: profile.id)
                }
                .fullScreenCover(item: $viewModel.showingEditEvent) { event in
                    AddEditEventView(profileId: profile.id, event: event)
                }
                .onAppear {
                    // Скрываем таб бар с анимацией
                    if let tabBarController = findTabBarController() {
                        UIView.animate(withDuration: 0.3) {
                            tabBarController.tabBar.alpha = 0
                            tabBarController.tabBar.isHidden = true
                        }
                    }
                }
                .onDisappear {
                    // Показываем таб бар с анимацией
                    if let tabBarController = findTabBarController() {
                        tabBarController.tabBar.isHidden = false
                        UIView.animate(withDuration: 0.3) {
                            tabBarController.tabBar.alpha = 1
                        }
                    }
                }
            } else {
                Text("message.profile_not_found".localized)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func findTabBarController() -> UITabBarController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return nil
        }
        
        return findTabBarController(in: rootViewController)
    }
    
    private func findTabBarController(in viewController: UIViewController) -> UITabBarController? {
        if let tabBarController = viewController as? UITabBarController {
            return tabBarController
        }
        
        for child in viewController.children {
            if let tabBarController = findTabBarController(in: child) {
                return tabBarController
            }
        }
        
        return nil
    }
    
}
