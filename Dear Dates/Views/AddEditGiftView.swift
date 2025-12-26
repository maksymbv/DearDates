//
//  AddEditGiftView.swift
//  DearDates
//
//  Created on 2025
//

import SwiftUI

struct AddEditGiftView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var gift: Gift?
    let profileId: UUID
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var showingDeleteAlert = false
    
    init(profileId: UUID, gift: Gift? = nil) {
        self.profileId = profileId
        self.gift = gift
    }
    
    var isGiven: Bool {
        gift?.isGiven ?? false
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .light ? Color.appBackground : Color(.systemBackground))
                    .ignoresSafeArea()
                
                Form {
                    Section(header: Text("section.gifts_info".localized)) {
                        if isGiven {
                            Text(title)
                                .foregroundColor(.secondary)
                            
                            Text(description)
                                .foregroundColor(.secondary)
                                .frame(height: 100, alignment: .topLeading)
                        } else {
                            TextField("label.gift_title".localized, text: $title)
                            
                            TextEditor(text: $description)
                                .frame(height: 100)
                        }
                    }
                    
                    if gift != nil {
                        Section {
                            Button(role: .destructive, action: { showingDeleteAlert = true }) {
                                HStack {
                                    Spacer()
                                    Text("button.delete_gift".localized)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(gift == nil ? "navigation.new_gift".localized : (isGiven ? "navigation.gift".localized : "navigation.edit_gift".localized))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
                
                if !isGiven {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { saveGift() }) {
                            Image(systemName: "checkmark")
                        }
                        .disabled(title.isEmpty)
                    }
                }
            }
            .onAppear {
                if let gift = gift {
                    title = gift.title
                    description = gift.description
                }
            }
            .alert("message.delete_gift_confirm".localized, isPresented: $showingDeleteAlert) {
                Button("button.cancel".localized, role: .cancel) { }
                Button("button.delete".localized, role: .destructive) {
                    deleteGift()
                }
            } message: {
                Text("message.delete_gift_description".localized)
            }
        }
    }
    
    private func saveGift() {
        if let existingGift = gift {
            var updatedGift = existingGift
            updatedGift.title = title
            updatedGift.description = description
            dataManager.updateGift(updatedGift)
        } else {
            let newGift = Gift(
                profileId: profileId,
                title: title,
                description: description
            )
            dataManager.addGift(newGift)
        }
        
        dismiss()
    }
    
    private func deleteGift() {
        guard let gift = gift else { return }
        dataManager.deleteGift(gift)
        dismiss()
    }
}

