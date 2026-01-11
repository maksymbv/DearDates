//
//  EasterEggView.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI

struct EasterEggView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .light ? Color.appBackground : Color(.systemBackground))
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("easteregg.message".localized)
                            .font(.body)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(6)
                            .padding()
                    }
                }
            }
            .navigationTitle("easteregg.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}
