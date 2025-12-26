//
//  GroupEditView.swift
//  DearDates
//
//  Created on 2025
//

import SwiftUI

struct GroupEditView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.colorScheme) var colorScheme
    
    let group: Group
    var onDelete: (() -> Void)? = nil
    @State private var name: String = ""
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ZStack {
            (colorScheme == .light ? Color.appBackground : Color(.systemBackground))
                .ignoresSafeArea()
            
            Form {
                Section(header: Text("label.group_name".localized)) {
                    TextField("label.name".localized, text: $name)
                }
                
                Section {
                    Button(role: .destructive, action: { showingDeleteAlert = true }) {
                        HStack {
                            Spacer()
                            Text("button.delete_group".localized)
                            Spacer()
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("navigation.edit_group".localized)
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
        .alert("message.delete_group_confirm".localized, isPresented: $showingDeleteAlert) {
            Button("button.cancel".localized, role: .cancel) { }
            Button("button.delete".localized, role: .destructive) {
                dataManager.deleteGroup(group)
                onDelete?()
                dismiss()
            }
        } message: {
            let profilesCount = dataManager.profiles.filter { $0.groupId == group.id }.count
            let format = localizationManager.localizedString("message.delete_group_description")
            let message = String(format: format, group.name, profilesCount)
            Text(message)
        }
        .onAppear {
            name = group.name
        }
    }
    
    private func saveGroup() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        var updatedGroup = group
        updatedGroup.name = trimmedName
        dataManager.updateGroup(updatedGroup)
        
        dismiss()
    }
}
