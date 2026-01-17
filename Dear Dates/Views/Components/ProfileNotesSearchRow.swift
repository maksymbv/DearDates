//
//  ProfileNotesSearchRow.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI

struct ProfileNotesSearchRow: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var settingsManager: SettingsManager
    let profile: Profile
    let searchText: String?
    
    init(profile: Profile, searchText: String? = nil) {
        self.profile = profile
        self.searchText = searchText
    }
    
    private var accentColor: Color {
        settingsManager.accentColor.color
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HighlightedText(
                profile.notes,
                searchText: searchText ?? "",
                highlightColor: accentColor
            )
            .font(.body)
            .foregroundColor(.primary)
            .lineLimit(3)
            .truncationMode(.tail)
            
            HighlightedText(
                profile.name,
                searchText: searchText ?? "",
                highlightColor: accentColor
            )
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(colorScheme == .light ? Color.white : Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(
            color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.05),
            radius: 5,
            x: 0,
            y: 2
        )
    }
}
