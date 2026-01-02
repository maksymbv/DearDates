//
//  EmptyStateView.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.and.background.dotted")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
                .accessibilityHidden(true)
            
            Text("empty.no_profiles_title".localized)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("empty.no_profiles_message".localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("empty.no_profiles_title".localized + ". " + "empty.no_profiles_message".localized)
    }
}
