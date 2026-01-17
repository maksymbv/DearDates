//
//  GiftIdeaSearchRow.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI
import SwiftData

struct GiftIdeaSearchRow: View {
    @Query private var allEvents: [CustomEvent]
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
    
    private var event: CustomEvent? {
        guard let eventId = gift.eventId else { return nil }
        return allEvents.first { $0.id == eventId }
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
                
                HStack(spacing: 8) {
                    HighlightedText(
                        profile.name,
                        searchText: searchText ?? "",
                        highlightColor: accentColor
                    )
                    .font(.subheadline) // Увеличен с .caption2 до .subheadline
                    .foregroundColor(.secondary)
                    
                    if let event = event {
                        Text(event.name)
                            .font(.caption)
                            .foregroundColor(accentColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(accentColor.opacity(0.15))
                            .cornerRadius(8)
                    }
                }
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
