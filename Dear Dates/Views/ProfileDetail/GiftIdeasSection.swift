//
//  GiftIdeasSection.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI

struct GiftIdeasSection: View {
    let giftIdeas: [Gift]
    let onAddGift: () -> Void
    let onEditGift: (Gift) -> Void
    
    var body: some View {
        Group {
            if giftIdeas.isEmpty {
                Text("message.gift_ideas_placeholder".localized)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(giftIdeas) { gift in
                    GiftRowView(gift: gift, isIdea: true, onEdit: {
                        onEditGift(gift)
                    })
                }
            }
        }
    }
}

