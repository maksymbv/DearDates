//
//  LanguageSettingsView.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI

struct LanguageSettingsView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var settingsManager: SettingsManager
    var onDismiss: () -> Void = {}
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            Form {
                Section(header: Text("settings.language".localized)) {
                    ForEach(AppLanguage.allCases, id: \.self) { language in
                        Button(action: {
                            localizationManager.setLanguage(language)
                        }) {
                            HStack {
                                Text(language.displayName)
                                Spacer()
                                if localizationManager.currentLanguage == language {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(settingsManager.accentColor.color)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("settings.language".localized)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { TabBarHelper.hideTabBar() }
        .onDisappear { onDismiss() }
    }
}
