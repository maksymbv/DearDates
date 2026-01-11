//
//  SettingsAboutSection.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI

struct SettingsAboutSection: View {
    let appVersion: String
    let onVersionLongPress: () -> Void
    
    var body: some View {
        Section(header: Text("settings.about".localized)) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("label.version".localized)
                    Spacer()
                    Text(appVersion)
                        .foregroundColor(.secondary)
                }
                
                Text("message.app_description".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
            .contentShape(Rectangle())
            .onLongPressGesture(minimumDuration: 0.5) {
                onVersionLongPress()
            }
        }
    }
}

