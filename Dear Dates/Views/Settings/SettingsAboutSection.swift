//
//  SettingsAboutSection.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI

struct SettingsAboutSection: View {
    let appVersion: String
    
    var body: some View {
        Section(header: Text("settings.about".localized)) {
            HStack {
                Text("label.version".localized)
                Spacer()
                Text(appVersion)
                    .foregroundColor(.secondary)
            }
            
            Text("message.app_description".localized)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

