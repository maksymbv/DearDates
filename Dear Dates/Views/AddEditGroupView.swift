//
//  AddEditGroupView.swift
//  DearDates
//
//  Created on 2025
//

import SwiftUI

struct AddEditGroupView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.colorScheme) var colorScheme
    
    var group: Group? = nil
    @State private var name: String = ""
    
    var body: some View {
        ZStack {
            (colorScheme == .light ? Color.appBackground : Color(.systemBackground))
                .ignoresSafeArea()
            
            Form {
                Section(header: Text("label.group_name".localized)) {
                    TextField("label.name".localized, text: $name)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(group == nil ? "navigation.new_group".localized : "navigation.edit_group".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { saveGroup() }) {
                    Image(systemName: "checkmark")
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .onAppear {
            if let group = group {
                name = group.name
            }
        }
    }
    
    private func saveGroup() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        if let existingGroup = group {
            var updatedGroup = existingGroup
            updatedGroup.name = trimmedName
            dataManager.updateGroup(updatedGroup)
        } else {
            let newGroup = Group(name: trimmedName)
            dataManager.addGroup(newGroup)
        }
        
        dismiss()
    }
}
