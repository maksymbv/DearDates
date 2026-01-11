//
//  CalendarView.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI
import SwiftData
import UIKit

// Структура для хранения даты события (только месяц и день)
struct EventDate: Hashable {
    let month: Int
    let day: Int
}

struct CalendarView: View {
    @Query private var allProfiles: [Profile]
    @Query private var allEvents: [CustomEvent]
    
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedDate: Date? = nil
    @State private var visibleDate = Date()
    
    var selectedDayProfiles: [Profile] {
        guard let date = selectedDate else { return [] }
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        
        // Фильтруем профили, у которых есть события в выбранный день
        return allProfiles.filter { profile in
            let profileEvents = allEvents.filter { $0.profileId == profile.id }
            return profileEvents.contains { event in
                let eventDay = calendar.component(.day, from: event.nextDate)
                let eventMonth = calendar.component(.month, from: event.nextDate)
                return eventDay == day && eventMonth == month
            }
        }
    }
    
    var selectedDayString: String {
        guard let date = selectedDate else { return "" }
        return DateFormatterHelper.formatEventDate(date, locale: localizationManager.currentLanguage.locale)
    }
    
    // Проверяем, есть ли события сегодня
    var hasEventsToday: Bool {
        let calendar = Calendar.current
        let today = Date()
        let todayDay = calendar.component(.day, from: today)
        let todayMonth = calendar.component(.month, from: today)
        
        return allEvents.contains { event in
            let eventDay = calendar.component(.day, from: event.nextDate)
            let eventMonth = calendar.component(.month, from: event.nextDate)
            return eventDay == todayDay && eventMonth == todayMonth
        }
    }
    
    // Находим ближайшее событие
    var nearestEvent: (date: Date, profile: Profile)? {
        let today = Date()
        
        // Находим все пользовательские события в будущем
        var upcomingEvents: [(date: Date, profile: Profile)] = []
        
        for event in allEvents {
            let eventDate = event.nextDate
            if eventDate >= today {
                if let profile = allProfiles.first(where: { $0.id == event.profileId }) {
                    upcomingEvents.append((date: eventDate, profile: profile))
                }
            }
        }
        
        // Сортируем по дате и возвращаем ближайшее
        return upcomingEvents.sorted { $0.date < $1.date }.first
    }
    
    // Проверяем, нужно ли показывать плашку
    var shouldShowNoEventsBanner: Bool {
        // Показываем, если выбран сегодня или ничего не выбрано, и нет событий сегодня
        let isTodaySelected = if let date = selectedDate {
            Calendar.current.isDateInToday(date)
        } else {
            false
        }
        let isNothingSelected = selectedDate == nil
        
        return (isTodaySelected || isNothingSelected) && !hasEventsToday && nearestEvent != nil
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Нативный календарь iOS
                    iOSCalendarView(
                        visibleDate: $visibleDate,
                        selectedDate: $selectedDate,
                        events: allEvents,
                        locale: localizationManager.currentLanguage.locale
                    )
                    .id(allEvents.count) // Принудительное обновление при изменении количества событий
                    .frame(height: 400)
                    .padding(.vertical)
                    .padding(.top, 8)
                    
                    // Плашка "На сегодня событий нет" с ближайшим событием
                    if shouldShowNoEventsBanner, let nearest = nearestEvent {
                        noEventsBanner(nearestEvent: nearest)
                            .padding(.horizontal)
                            .padding(.top, 24)
                    }
                    
                    // Профили выбранного дня (показываем только если есть дни рождения)
                    if selectedDate != nil && !selectedDayProfiles.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                                Text(selectedDayString)
                                    .font(.headline)
                                    .padding(.horizontal)
                                    .padding(.top, 24)
                                
                                LazyVStack(spacing: 12) {
                                    ForEach(selectedDayProfiles) { profile in
                                        NavigationLink(destination: ProfileDetailView(profileId: profile.id)) {
                                            ProfileRowView(
                                                profile: profile,
                                                locale: localizationManager.currentLanguage.locale
                                            )
                                            .transition(.opacity.combined(with: .move(edge: .top)))
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            .animation(.easeInOut(duration: AppConstants.UI.animationDuration), value: selectedDate)
                        }
                    }
                }
            }
            .navigationTitle("navigation.calendar".localized)
            .appBackground(colorScheme: colorScheme)
            .onAppear {
                // При появлении View проверяем, нужно ли выбрать сегодня
                // Если ничего не выбрано, проверяем есть ли события сегодня
                if selectedDate == nil && hasEventsToday {
                    selectedDate = Date()
                    visibleDate = Date()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Всегда переходим на сегодняшний день
                        let today = Date()
                        visibleDate = today
                        selectedDate = today
                    }) {
                        Text("button.today".localized)
                            .foregroundColor(settingsManager.accentColor == .pink ? .pink : .blue)
                    }
                }
            }
        }
    }
    
    // MARK: - No Events Banner
    
    private func noEventsBanner(nearestEvent: (date: Date, profile: Profile)) -> some View {
        let formattedDate = DateFormatterHelper.formatEventDate(nearestEvent.date, locale: localizationManager.currentLanguage.locale)
        
        return Button(action: {
            // Переходим на день с ближайшим событием
            selectedDate = nearestEvent.date
            visibleDate = nearestEvent.date
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("message.no_events_today".localized)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text("\(localizationManager.localizedString("message.nearest_event")) \(formattedDate)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(colorScheme == .light ? Color.white : Color(.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(
                color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.05),
                radius: 5,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Обертка для UICalendarView
struct iOSCalendarView: UIViewRepresentable {
    @Binding var visibleDate: Date
    @Binding var selectedDate: Date?
    let events: [CustomEvent]
    let locale: Locale
    
    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        let calendar = Calendar.current
        calendarView.calendar = calendar
        calendarView.locale = locale
        calendarView.fontDesign = .rounded
        calendarView.delegate = context.coordinator
        calendarView.selectionBehavior = UICalendarSelectionSingleDate(delegate: context.coordinator)
        
        // Устанавливаем диапазон дат: 10 лет назад и 10 лет вперед от текущей даты
        let today = Date()
        let minDate = calendar.date(byAdding: .year, value: -10, to: today) ?? today
        let maxDate = calendar.date(byAdding: .year, value: 10, to: today) ?? today
        calendarView.availableDateRange = DateInterval(start: minDate, end: maxDate)
        
        // Устанавливаем видимую дату
        calendarView.visibleDateComponents = calendar.dateComponents([.year, .month], from: visibleDate)
        
        return calendarView
    }
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
        uiView.locale = locale
        let calendar = Calendar.current
        let currentVisibleComponents = calendar.dateComponents([.year, .month], from: visibleDate)
        
        // Всегда задаем visibleDateComponents из visibleDate
        uiView.visibleDateComponents = currentVisibleComponents
        
        // Обновляем выбранную дату в календаре
        if let selectionBehavior = uiView.selectionBehavior as? UICalendarSelectionSingleDate {
            if let selectedDate = selectedDate {
                let components = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
                selectionBehavior.setSelected(components, animated: false)
            } else {
                // Сбрасываем выбор, если selectedDate = nil
                selectionBehavior.setSelected(nil, animated: false)
            }
        }
        
        // Обновляем декораторы для событий
        // Декоратор должен показываться каждый год, поэтому проверяем только день и месяц
        context.coordinator.eventDays = Set(events.map { event in
            let day = calendar.component(.day, from: event.nextDate)
            let month = calendar.component(.month, from: event.nextDate)
            return EventDate(month: month, day: day)
        })
        
        uiView.delegate = context.coordinator
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: iOSCalendarView
        var eventDays: Set<EventDate> = []
        
        init(_ parent: iOSCalendarView) {
            self.parent = parent
        }
        
        // MARK: - UICalendarViewDelegate
        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            guard let month = dateComponents.month,
                  let day = dateComponents.day else {
                return nil
            }
            
            // Проверяем, есть ли событие в этот день и месяц (любой год)
            if eventDays.contains(EventDate(month: month, day: day)) {
                return UICalendarView.Decoration.default(color: .systemRed, size: .small)
            }
            
            return nil
        }
        
        // MARK: - UICalendarSelectionSingleDateDelegate
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            guard let components = dateComponents,
                  let date = Calendar.current.date(from: components) else {
                parent.selectedDate = nil
                return
            }
            
            parent.selectedDate = date
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate, canSelectDate dateComponents: DateComponents?) -> Bool {
            guard let components = dateComponents,
                  let month = components.month,
                  let day = components.day else {
                return false
            }
            
            // Разрешаем выбор только дней с событиями
            return eventDays.contains(EventDate(month: month, day: day))
        }
    }
}
