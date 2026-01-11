//
//  GiftIdeaSearchRow.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI

struct GiftIdeaSearchRow: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var settingsManager: SettingsManager
    let gift: Gift
    let profile: Profile
    let searchText: String?
    
    init(gift: Gift, profile: Profile, searchText: String? = nil) {
        self.gift = gift
        self.profile = profile
        self.searchText = searchText
    }
    
    private var accentColor: Color {
        settingsManager.accentColor.color
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HighlightedText(
                    gift.title,
                    searchText: searchText ?? "",
                    highlightColor: accentColor
                )
                .font(.headline)
                .foregroundColor(.primary)
                
                if !gift.notes.isEmpty {
                    HighlightedText(
                        gift.notes,
                        searchText: searchText ?? "",
                        highlightColor: accentColor
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .truncationMode(.tail)
                }
                
                HighlightedText(
                    profile.name,
                    searchText: searchText ?? "",
                    highlightColor: accentColor
                )
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.top, 2)
            }
            
            Spacer()
        }
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
