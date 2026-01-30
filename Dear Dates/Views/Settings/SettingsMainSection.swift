//
//  SettingsMainSection.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI
import Combine

struct SettingsMainSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        Section(header: Text("settings.main".localized)) {
            Button(action: { viewModel.showingThemeSettings = true }) {
                HStack {
                    Image(systemName: "paintbrush.fill")
                        .foregroundColor(.blue)
                        .frame(width: 30)
                        .accessibilityHidden(true)
                    Text("section.appearance".localized)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(.primary)
            .accessibilityLabel("accessibility.appearance_settings".localized)
            
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(.orange)
                    .frame(width: 30)
                    .accessibilityHidden(true)
                Text("navigation.notifications".localized)
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                Spacer()
                Toggle("", isOn: $settingsManager.notificationsEnabled)
                    .labelsHidden()
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("accessibility.notifications_settings".localized)
            .accessibilityValue(settingsManager.notificationsEnabled ? "label.enable_notifications".localized : "message.notifications_disabled".localized)
            
            Button(action: { viewModel.showingLanguageSettings = true }) {
                HStack {
                    Image(systemName: "globe")
                        .foregroundColor(.blue)
                        .frame(width: 30)
                        .accessibilityHidden(true)
                    Text("settings.language".localized)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    Spacer()
                    Text(localizationManager.currentLanguage.displayName)
                        .foregroundColor(.secondary)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(.primary)
            .accessibilityLabel("accessibility.language_settings".localized)
        }
    }
}

