//
//  GiftRowView.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI
import SwiftData

struct GiftRowView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    @Query private var allEvents: [CustomEvent]
    
    let gift: Gift
    let isIdea: Bool
    var onEdit: (() -> Void)? = nil
    @State private var showingDeleteAlert = false
    
    private var linkedEvent: CustomEvent? {
        guard let eventId = gift.eventId else { return nil }
        return allEvents.first { $0.id == eventId }
    }
    
    var body: some View {
        HStack {
            // Основная часть - клик открывает редактирование
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(gift.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    
                    if !gift.notes.isEmpty {
                        Text(gift.notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                            .truncationMode(.tail)
                            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    }
                    
                    if let event = linkedEvent {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption2)
                            Text(event.name)
                                .font(.caption2)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(settingsManager.accentColor.color)
                        .cornerRadius(8)
                    }
                }
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if let onEdit = onEdit {
                    onEdit()
                }
            }
            
            // Чекбокс - клик отмечает как подаренный
            if isIdea {
                Button(action: { 
                    markAsGiven()
                }) {
                    Image(systemName: gift.isGiven ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(gift.isGiven ? .green : .gray)
                        .font(.title3)
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("accessibility.mark_gift_given".localized)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("accessibility.gift_row".localized + " \(gift.title)" + (gift.notes.isEmpty ? "" : ", \(gift.notes)"))
        .accessibilityHint(isIdea ? "accessibility.gift_row_hint_idea".localized : "accessibility.gift_row_hint".localized)
    }
    
    private func markAsGiven() {
        gift.isGiven = true
        gift.givenYear = Calendar.current.component(.year, from: Date())
        dataManager.updateGift(gift, context: modelContext)
    }
}

extension GiftRowView: Equatable {
    static func == (lhs: GiftRowView, rhs: GiftRowView) -> Bool {
        lhs.gift.id == rhs.gift.id &&
        lhs.gift.isGiven == rhs.gift.isGiven &&
        lhs.gift.eventId == rhs.gift.eventId &&
        lhs.isIdea == rhs.isIdea
    }
}
