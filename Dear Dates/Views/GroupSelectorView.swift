//
//  GroupSelectorView.swift
//  DearDates
//
//  Created on 2025
//

import SwiftUI

struct GroupSelectorView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var onSelect: (UUID?) -> Void
    
    var body: some View {
        ZStack {
            (colorScheme == .light ? Color.appBackground : Color(.systemBackground))
                .ignoresSafeArea()
            
            List {
                Button(action: {
                    onSelect(nil)
                    dismiss()
                }) {
                    HStack {
                        Text("label.no_group_option".localized)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
                
                ForEach(dataManager.groups) { group in
                    Button(action: {
                        onSelect(group.id)
                        dismiss()
                    }) {
                        HStack {
                            Text(group.name)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("navigation.select_group".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                }
            }
        }
    }
}
