//
//  AddEditGiftView.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI
import SwiftData
import UIKit

struct AddEditGiftView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    @Query private var allEvents: [CustomEvent]
    
    var gift: Gift?
    let profileId: UUID
    
    @State private var fullText: String = ""
    @State private var selectedEventId: UUID? = nil
    @State private var showingDeleteAlert = false
    @State private var showingEventPicker = false
    @State private var skipAutoSave = false
    
    private var profileEvents: [CustomEvent] {
        allEvents.filter { $0.profileId == profileId }
            .sorted { $0.nextDate < $1.nextDate }
    }
    
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
        ZStack {
            // Адаптивный фон
            Color(.systemGroupedBackground)
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
                .navigationTitle(gift == nil ? "navigation.new_gift".localized : (isGiven ? "navigation.gift".localized : "navigation.edit_gift".localized))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
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
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    // Футер с выбором события
                    if !isGiven && !profileEvents.isEmpty {
                        eventSelectionFooter
                    }
                }
                .onAppear {
                    TabBarHelper.hideTabBar()
                    if let gift = gift {
                        // Объединяем title и description в один текст
                        if gift.notes.isEmpty {
                            fullText = gift.title
                        } else {
                            fullText = "\(gift.title)\n\(gift.notes)"
                        }
                        selectedEventId = gift.eventId
                    }
                }
                .onDisappear {
                    // Таб-бар не показываем: возврат в профиль, показ при уходе с профиля
                    if !skipAutoSave { commitGiftIfNeeded() }
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .background, !isGiven, !skipAutoSave {
                        commitGiftIfNeeded()
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
                .sheet(isPresented: $showingEventPicker) {
                    eventPickerSheet
                }
        }
        .ignoresSafeArea(edges: .bottom) // Таб-бар скрыт — не резервировать под него место
        // Акцент только в футере и sheet выбора события; кнопки (три точки и т.д.) — системный цвет
    }
    
    /// Безопасное автосохранение при уходе с экрана: сохраняет только при непустом тексте.
    /// Пустую новую идею не создаёт; существующую идею, очищенную до пустоты, удаляет.
    private func commitGiftIfNeeded() {
        let trimmed = fullText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            if let existingGift = gift {
                dataManager.deleteGift(existingGift, context: modelContext)
            }
            return
        }
        let lines = fullText.components(separatedBy: .newlines)
        let giftTitle = lines.first?.trimmingCharacters(in: .whitespaces) ?? ""
        let giftDescription: String
        if lines.count > 1 {
            giftDescription = lines[1...].joined(separator: "\n").trimmingCharacters(in: .whitespaces)
        } else {
            giftDescription = ""
        }
        if giftTitle.isEmpty { return }
        if let existingGift = gift {
            existingGift.title = giftTitle
            existingGift.notes = giftDescription
            existingGift.eventId = selectedEventId
            dataManager.updateGift(existingGift, context: modelContext)
        } else {
            let newGift = Gift(
                profileId: profileId,
                title: giftTitle,
                notes: giftDescription,
                eventId: selectedEventId
            )
            dataManager.addGift(newGift, context: modelContext)
        }
    }
    
    private func deleteGift() {
        guard let gift = gift else { return }
        skipAutoSave = true
        dataManager.deleteGift(gift, context: modelContext)
        dismiss()
    }
    
    // MARK: - Event Selection Footer (без Menu — избегаем _UIReparentingView)
    
    private var eventSelectionFooter: some View {
        HStack {
            Text("section.add_to_event".localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: { showingEventPicker = true }) {
                HStack(spacing: 4) {
                    if let selectedEventId = selectedEventId,
                       let selectedEvent = profileEvents.first(where: { $0.id == selectedEventId }) {
                        Text(selectedEvent.name)
                            .font(.body)
                            .foregroundColor(settingsManager.accentColor.color)
                    } else {
                        Text("label.not_selected".localized)
                            .font(.body)
                            .foregroundColor(settingsManager.accentColor.color)
                    }
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundColor(settingsManager.accentColor.color)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .padding(.bottom, 24) // Отступ под home indicator (таб-бар скрыт)
        .background(
            Color(.systemBackground)
        )
    }
    
    private var eventPickerSheet: some View {
        NavigationStack {
            List {
                Button(action: {
                    selectedEventId = nil
                    showingEventPicker = false
                }) {
                    HStack {
                        Text("label.not_selected".localized)
                        Spacer()
                        if selectedEventId == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(settingsManager.accentColor.color)
                        }
                    }
                }
                .foregroundColor(.primary)
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                .listRowBackground(Color.clear)
                
                ForEach(profileEvents, id: \.id) { event in
                    Button(action: {
                        selectedEventId = event.id
                        showingEventPicker = false
                    }) {
                        HStack {
                            Text(event.name)
                            Spacer()
                            if selectedEventId == event.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(settingsManager.accentColor.color)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .contentMargins(.top, 0, for: .scrollContent)
            .contentMargins(.horizontal, 0, for: .scrollContent)
            .navigationTitle("section.add_to_event".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("button.cancel".localized) {
                        showingEventPicker = false
                    }
                    .tint(settingsManager.accentColor.color)
                }
            }
        }
        .presentationDetents([.height(340)])
        .presentationDragIndicator(.visible)
        .tint(settingsManager.accentColor.color)
    }
}

