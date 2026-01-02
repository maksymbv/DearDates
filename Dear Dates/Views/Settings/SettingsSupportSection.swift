//
//  SettingsSupportSection.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI

struct SettingsSupportSection: View {
    let onReportBug: () -> Void
    let onRequestFeature: () -> Void
    
    var body: some View {
        Section(header: Text("settings.other".localized)) {
            Button(action: onReportBug) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .frame(width: 30)
                        .accessibilityHidden(true)
                    Text("settings.report_bug".localized)
                        .foregroundColor(.primary)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                }
            }
            .accessibilityLabel("accessibility.report_bug".localized)
            
            Button(action: onRequestFeature) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                        .frame(width: 30)
                        .accessibilityHidden(true)
                    Text("settings.request_feature".localized)
                        .foregroundColor(.primary)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                }
            }
            .accessibilityLabel("accessibility.request_feature".localized)
        }
    }
}

