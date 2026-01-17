//
//  AddEditEventView.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI
import SwiftData

struct AddEditEventView: View {
    @Query private var allProfiles: [Profile]
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    let profileId: UUID
    var event: CustomEvent?
    
    private var profile: Profile? {
        allProfiles.first { $0.id == profileId }
    }
    
    @State private var eventName: String = ""
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedDay: Int = Calendar.current.component(.day, from: Date())
    @State private var remindAnnually: Bool = true
    @State private var showingDeleteAlert = false
    @State private var showingDatePicker = false
    
    private var validDays: [Int] {
        let calendar = Calendar.current
        guard let date = calendar.date(from: DateComponents(year: 2000, month: selectedMonth, day: 1)),
              let range = calendar.range(of: .day, in: .month, for: date) else {
            // Fallback: return days 1-31 if date calculation fails
            return Array(1...31)
        }
        return Array(range)
    }
    
    private func monthName(_ month: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = localizationManager.currentLanguage.locale
        return dateFormatter.monthSymbols[month - 1]
    }
    
    init(profileId: UUID, event: CustomEvent? = nil) {
        self.profileId = profileId
        self.event = event
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                Form {
                    Section(header: Text("label.event_name".localized)) {
                        TextField("label.event_name_placeholder".localized, text: Binding(
                            get: { eventName },
                            set: { newValue in
                                if newValue.count <= AppConstants.TextLimits.maxEventNameLength {
                                    eventName = newValue
                                }
                            }
                        ))
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    }
                    
                    Section(header: Text("label.event_date".localized)) {
                        Button(action: {
                            showingDatePicker = true
                        }) {
                            HStack {
                                Text("\(selectedDay) \(monthName(selectedMonth))")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Section {
                        Toggle("label.remind_annually".localized, isOn: $remindAnnually)
                            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    }
                    
                    // Кнопка удаления (только для редактирования существующего события)
                    if event != nil {
                        Section {
                            Button(role: .destructive, action: {
                                showingDeleteAlert = true
                            }) {
                                HStack {
                                    Spacer()
                                    Text("button.delete".localized)
                                    Spacer()
                                }
                            }
                            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(event == nil ? "button.add_event".localized : "button.edit".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Кнопка сохранения
                    Button(action: { saveEvent() }) {
                        Image(systemName: "checkmark")
                    }
                    .disabled(eventName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                loadEvent()
            }
            .alert("message.delete_event_confirm".localized, isPresented: $showingDeleteAlert) {
                Button("button.cancel".localized, role: .cancel) { }
                Button("button.delete".localized, role: .destructive) {
                    deleteEvent()
                }
            } message: {
                Text("message.delete_event_description".localized)
            }
            .sheet(isPresented: $showingDatePicker) {
                datePickerSheet
                    .presentationDetents([.height(250)])
            }
            .tint(settingsManager.accentColor.color)
        }
    }
    
    private var datePickerSheet: some View {
        NavigationView {
            HStack(spacing: 0) {
                // Picker для дня (первый)
                Picker("label.day".localized, selection: $selectedDay) {
                    ForEach(validDays, id: \.self) { day in
                        Text("\(day)")
                            .tag(day)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                .onChange(of: selectedMonth) { oldValue, newValue in
                    // Обновляем день при изменении месяца, если текущий день невалиден
                    if selectedDay > validDays.count {
                        selectedDay = validDays.count
                    }
                }
                
                // Picker для месяца (второй)
                Picker("label.month".localized, selection: $selectedMonth) {
                    ForEach(1...12, id: \.self) { month in
                        Text(monthName(month))
                            .tag(month)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            .frame(height: 200)
            .navigationTitle("label.event_date".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingDatePicker = false
                    }) {
                        Image(systemName: "xmark")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingDatePicker = false
                    }) {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
    }
    
    private func loadEvent() {
        if let event = event {
            eventName = event.name
            selectedMonth = event.month
            selectedDay = event.day
            remindAnnually = event.remindAnnually
        }
    }
    
    private func saveEvent() {
        let trimmedName = eventName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        guard let profile = profile else {
            AppLogger.log("Profile not found for profileId: \(profileId)", level: .error, category: "AddEditEventView")
            return
        }
        
        // Используем выбранные месяц и день напрямую
        let month = selectedMonth
        let day = min(selectedDay, validDays.count) // Убеждаемся, что день валиден
        
        let eventToSave: CustomEvent
        
        if let existingEvent = event {
            // Отменяем старые уведомления
            notificationManager.cancelNotifications(for: existingEvent)
            
            existingEvent.name = trimmedName
            existingEvent.month = month
            existingEvent.day = day
            existingEvent.remindAnnually = remindAnnually
            existingEvent.updatedAt = Date()
            eventToSave = existingEvent
        } else {
            let newEvent = CustomEvent(
                profileId: profileId,
                name: trimmedName,
                month: month,
                day: day,
                remindAnnually: remindAnnually
            )
            modelContext.insert(newEvent)
            eventToSave = newEvent
        }
        
        do {
            try modelContext.save()
            
            // Планируем уведомления (используем snapshot, не читаем основную БД)
            if profile.notificationsEnabled && eventToSave.remindAnnually {
                notificationManager.scheduleNotifications(
                    for: eventToSave,
                    profileName: profile.name,
                    reminderDays: profile.reminderDays
                )
            }
            
            dismiss()
        } catch {
            AppLogger.log("Error saving event: \(error.localizedDescription)", level: .error, category: "AddEditEventView")
            ErrorManager.shared.showError(.dataSaveFailed(error.localizedDescription))
        }
    }
    
    private func deleteEvent() {
        guard let event = event else { return }
        
        // Отменяем уведомления перед удалением
        notificationManager.cancelNotifications(for: event)
        
        modelContext.delete(event)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            AppLogger.log("Error deleting event: \(error.localizedDescription)", level: .error, category: "AddEditEventView")
            ErrorManager.shared.showError(.dataSaveFailed(error.localizedDescription))
        }
    }
    
}

