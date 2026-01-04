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
    @State private var isMarkingAsGiven = false
    
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
                        .lineLimit(2)
                        .truncationMode(.tail)
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
                        .foregroundColor(settingsManager.accentColor.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(settingsManager.accentColor.color.opacity(0.1))
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
            
            // Иконка подарка - клик отмечает как подаренный
            if isIdea && !isMarkingAsGiven {
                Button(action: { 
                    isMarkingAsGiven = true
                    
                    // Сначала закрашиваем подарок
                    withAnimation(.easeInOut(duration: 0.5)) {
                        gift.isGiven = true
                    }
                    
                    // Затем через задержку обновляем данные и карточка исчезнет
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            gift.givenYear = Calendar.current.component(.year, from: Date())
                            dataManager.updateGift(gift, context: modelContext)
                        }
                    }
                }) {
                    Image(systemName: "gift.fill")
                        .foregroundColor(gift.isGiven ? settingsManager.accentColor.color : .gray)
                        .font(.title3)
                        .animation(.easeInOut(duration: 0.5), value: gift.isGiven)
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("accessibility.mark_gift_given".localized)
            } else if isIdea {
                // Показываем закрашенный подарок во время анимации
                Image(systemName: "gift.fill")
                    .foregroundColor(settingsManager.accentColor.color)
                    .font(.title3)
            }
        }
        .opacity(isMarkingAsGiven ? 0 : 1)
        .animation(.easeInOut(duration: 0.3).delay(0.5), value: isMarkingAsGiven)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("accessibility.gift_row".localized + " \(gift.title)" + (gift.notes.isEmpty ? "" : ", \(gift.notes)"))
        .accessibilityHint(isIdea ? "accessibility.gift_row_hint_idea".localized : "accessibility.gift_row_hint".localized)
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
