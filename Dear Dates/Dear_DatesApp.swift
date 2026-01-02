//
//  DearDatesApp.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI
import SwiftData

@main
struct DearDatesApp: App {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var settingsManager = SettingsManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var imageManager = ImageManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var errorManager = ErrorManager.shared
    
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "OnboardingCompleted")
    
    var body: some Scene {
        WindowGroup {
            if showOnboarding {
                OnboardingView(isPresented: $showOnboarding)
                    .environmentObject(dataManager)
                    .environmentObject(settingsManager)
                    .environmentObject(localizationManager)
                    .environmentObject(imageManager)
                    .environmentObject(notificationManager)
                    .errorAlert()
            } else {
                ContentView()
                    .id("mainContentView")
                    .environmentObject(dataManager)
                    .environmentObject(notificationManager)
                    .environmentObject(settingsManager)
                    .environmentObject(localizationManager)
                    .environmentObject(imageManager)
                    .errorAlert()
            }
        }
        .modelContainer(for: [Profile.self, Gift.self, UserProfile.self, CustomEvent.self])
    }
}
