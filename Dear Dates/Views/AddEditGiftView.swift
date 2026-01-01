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
    
    @State private var fullText: String = ""
    @State private var showingDeleteAlert = false
    
    private var title: String {
        let lines = fullText.components(separatedBy: .newlines)
        return lines.first?.trimmingCharacters(in: .whitespaces) ?? ""
    }
    
    private var description: String {
        let lines = fullText.components(separatedBy: .newlines)
        guard lines.count > 1 else { return "" }
        return lines[1...].joined(separator: "\n").trimmingCharacters(in: .whitespaces)
    }
    
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
                // Адаптивный фон
                (colorScheme == .light ? Color.white : Color(.systemBackground))
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if isGiven {
                        // Режим просмотра (для подаренных подарков)
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                if !title.isEmpty {
                                    Text(title)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                }
                                
                                if !description.isEmpty {
                                    Text(description)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        }
                    } else {
                        // Режим редактирования
                        GeometryReader { geometry in
                            ScrollView {
                                AutoExpandingTextEditor(
                                    text: $fullText,
                                    maxLength: AppConstants.TextLimits.maxDescriptionLength,
                                    placeholder: "\(localizationManager.localizedString("label.gift_title"))\n\(localizationManager.localizedString("label.gift_description"))",
                                    fixedWidth: geometry.size.width - 32
                                )
                                .frame(minHeight: 100)
                                .frame(width: geometry.size.width - 32)
                                .padding(.horizontal, 16)
                                .padding(.vertical)
                            }
                        }
                    }
                }
            }
            .navigationTitle(gift == nil ? "navigation.new_gift".localized : (isGiven ? "navigation.gift".localized : "navigation.edit_gift".localized))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Меню действий (для всех существующих подарков)
                    if gift != nil {
                        Menu {
                            Button(role: .destructive, action: { showingDeleteAlert = true }) {
                                Label("button.delete_gift".localized, systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                    
                    if !isGiven {
                        Button(action: { saveGift() }) {
                            Image(systemName: "checkmark")
                        }
                        .disabled(fullText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .onAppear {
                if let gift = gift {
                    // Объединяем title и description в один текст
                    if gift.description.isEmpty {
                        fullText = gift.title
                    } else {
                        fullText = "\(gift.title)\n\(gift.description)"
                    }
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
        let lines = fullText.components(separatedBy: .newlines)
        let giftTitle = lines.first?.trimmingCharacters(in: .whitespaces) ?? ""
        let giftDescription: String
        if lines.count > 1 {
            giftDescription = lines[1...].joined(separator: "\n").trimmingCharacters(in: .whitespaces)
        } else {
            giftDescription = ""
        }
        
        if let existingGift = gift {
            var updatedGift = existingGift
            updatedGift.title = giftTitle
            updatedGift.description = giftDescription
            dataManager.updateGift(updatedGift)
        } else {
            let newGift = Gift(
                profileId: profileId,
                title: giftTitle,
                description: giftDescription
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

