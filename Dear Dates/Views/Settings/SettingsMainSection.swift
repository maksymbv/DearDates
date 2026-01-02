//
//  SettingsMainSection.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI
import Combine

struct SettingsMainSection: View {
    var body: some View {
        Section(header: Text("settings.main".localized)) {
            NavigationLink(destination: ThemeSettingsView()) {
                HStack {
                    Image(systemName: "paintbrush.fill")
                        .foregroundColor(.blue)
                        .frame(width: 30)
                        .accessibilityHidden(true)
                    Text("section.appearance".localized)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                }
            }
            .accessibilityLabel("accessibility.appearance_settings".localized)
            
            NavigationLink(destination: NotificationsSettingsView()) {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.orange)
                        .frame(width: 30)
                        .accessibilityHidden(true)
                    Text("navigation.notifications".localized)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                }
            }
            .accessibilityLabel("accessibility.notifications_settings".localized)
        }
    }
}

