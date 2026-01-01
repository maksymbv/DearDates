//
//  GiftRowView.swift
//  DearDates
//
//  Created on 2025
//

import SwiftUI

struct GiftRowView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.colorScheme) var colorScheme
    
    let gift: Gift
    let isIdea: Bool
    var onEdit: (() -> Void)? = nil
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(gift.title)
                    .font(.body)
                    .fontWeight(.medium)
                
                if !gift.description.isEmpty {
                    Text(gift.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .truncationMode(.tail)
                }
            }
            
            Spacer()
            
            if isIdea {
                Button(action: { markAsGiven() }) {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                        .font(.title3)
                }
            }
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
        .padding(.horizontal)
        .contentShape(Rectangle())
        .onTapGesture {
            if let onEdit = onEdit {
                onEdit()
            }
        }
    }
    
    private func markAsGiven() {
        var updatedGift = gift
        updatedGift.isGiven = true
        updatedGift.givenYear = Calendar.current.component(.year, from: Date())
        dataManager.updateGift(updatedGift)
    }
}

extension GiftRowView: Equatable {
    static func == (lhs: GiftRowView, rhs: GiftRowView) -> Bool {
        lhs.gift.id == rhs.gift.id &&
        lhs.gift.isGiven == rhs.gift.isGiven &&
        lhs.isIdea == rhs.isIdea
    }
}
