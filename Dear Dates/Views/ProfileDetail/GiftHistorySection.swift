//
//  GiftHistorySection.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI

struct GiftHistorySection: View {
    let givenGifts: [Gift]
    let onEditGift: (Gift) -> Void
    
    @State private var isExpanded = false
    
    private var groupedGifts: [Int: [Gift]] {
        Gift.groupedByYear(givenGifts)
    }
    
    var body: some View {
        if !groupedGifts.isEmpty {
            DisclosureGroup(isExpanded: $isExpanded) {
                ForEach(groupedGifts.keys.sorted(by: >), id: \.self) { year in
                    YearGiftsSection(year: year, gifts: groupedGifts[year] ?? [], onEditGift: onEditGift)
                }
            } label: {
                Text("label.gift_history".localized)
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
            }
        }
    }
}

struct YearGiftsSection: View {
    let year: Int
    let gifts: [Gift]
    let onEditGift: (Gift) -> Void
    
    private var sortedGifts: [Gift] {
        gifts.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    var body: some View {
        Section {
            ForEach(sortedGifts) { gift in
                GiftRowView(gift: gift, isIdea: false, onEdit: {
                    onEditGift(gift)
                })
                .transition(.opacity.combined(with: .scale))
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
        } header: {
            Text("\(String(year))")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        .listSectionSeparator(.hidden)
    }
}

