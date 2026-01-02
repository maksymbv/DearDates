//
//  SettingsDataSection.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI

struct SettingsDataSection: View {
    let onExport: () -> Void
    let onImport: () -> Void
    
    var body: some View {
        Section(header: Text("settings.data".localized)) {
            Button(action: onExport) {
                HStack {
                    Image(systemName: "square.and.arrow.up.fill")
                        .foregroundColor(.blue)
                        .frame(width: 30)
                        .accessibilityHidden(true)
                    Text("settings.export_data".localized)
                        .foregroundColor(.primary)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                }
            }
            .accessibilityLabel("accessibility.export_data".localized)
            
            Button(action: onImport) {
                HStack {
                    Image(systemName: "square.and.arrow.down.fill")
                        .foregroundColor(.green)
                        .frame(width: 30)
                        .accessibilityHidden(true)
                    Text("settings.import_data".localized)
                        .foregroundColor(.primary)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                }
            }
            .accessibilityLabel("accessibility.import_data".localized)
        }
    }
}

