//
//  ProfileNotesSection.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI

struct ProfileNotesSection: View {
    let notes: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if !notes.isEmpty {
            Text(notes)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel("accessibility.notes".localized + ": \(notes)")
        }
    }
}

