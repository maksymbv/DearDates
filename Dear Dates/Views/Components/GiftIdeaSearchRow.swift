//
//  GiftIdeaSearchRow.swift
//  DearDates
//
//  Created on 2025
//

import SwiftUI

struct GiftIdeaSearchRow: View {
    @Environment(\.colorScheme) var colorScheme
    let gift: Gift
    let profile: Profile
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(gift.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if !gift.description.isEmpty {
                    Text(gift.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }
                
                Text(profile.name)
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
