//
//  DearDatesApp.swift
//  DearDates
//
//  Created on 2025
//

import SwiftUI

@main
struct DearDatesApp: App {
    private let dataManager = DataManager.shared
    private let notificationManager = NotificationManager.shared
    private let settingsManager = SettingsManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
                .environmentObject(notificationManager)
                .environmentObject(settingsManager)
        }
    }
}

