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
    
    var body: some View {
        Section {
            ForEach(gifts) { gift in
                GiftRowView(gift: gift, isIdea: false, onEdit: {
                    onEditGift(gift)
                })
            }
        } header: {
            Text("\(String(year))")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
        }
    }
}

