//
//  CalendarView.swift
//  DearDates
//
//  Created on 2025
//

import SwiftUI
import UIKit

// Структура для хранения даты дня рождения (только месяц и день)
struct BirthdayDate: Hashable {
    let month: Int
    let day: Int
}

struct CalendarView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedDate: Date? = nil
    @State private var visibleDate = Date()
    
    var selectedDayProfiles: [Profile] {
        guard let date = selectedDate else { return [] }
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        
        return dataManager.profiles.filter { profile in
            let profileDay = calendar.component(.day, from: profile.dateOfBirth)
            let profileMonth = calendar.component(.month, from: profile.dateOfBirth)
            return profileDay == day && profileMonth == month
        }
    }
    
    var selectedDayString: String {
        guard let date = selectedDate else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Нативный календарь iOS
                    iOSCalendarView(
                        visibleDate: $visibleDate,
                        selectedDate: $selectedDate,
                        profiles: dataManager.profiles
                    )
                    .frame(height: 400)
                    .padding(.vertical)
                    .padding(.top, 8)
                    
                    // Профили выбранного дня
                    if selectedDate != nil {
                        VStack(alignment: .leading, spacing: 12) {
                            if !selectedDayProfiles.isEmpty {
                                Text(selectedDayString)
                                    .font(.headline)
                                    .padding(.horizontal)
                                    .padding(.top, 24)
                                
                                LazyVStack(spacing: 12) {
                                    ForEach(selectedDayProfiles) { profile in
                                        NavigationLink(destination: ProfileDetailView(profile: profile)) {
                                            ProfileRowView(profile: profile)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            } else {
                                VStack(spacing: 12) {
                                    Text(selectedDayString)
                                        .font(.headline)
                                    
                                    Text("Нет дней рождения в этот день")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Календарь")
            .background(colorScheme == .light ? Color.appBackground : Color(.systemBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        visibleDate = Date()
                        selectedDate = Date()
                    }) {
                        Text("Сегодня")
                            .foregroundColor(settingsManager.accentColor == .pink ? .pink : .blue)
                    }
                }
            }
        }
    }
}

// Обертка для UICalendarView
struct iOSCalendarView: UIViewRepresentable {
    @Binding var visibleDate: Date
    @Binding var selectedDate: Date?
    let profiles: [Profile]
    
    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        let calendar = Calendar.current
        calendarView.calendar = calendar
        calendarView.locale = Locale(identifier: "ru_RU")
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
        // Обновляем видимую дату
        uiView.visibleDateComponents = Calendar.current.dateComponents([.year, .month], from: visibleDate)
        
        // Обновляем выбранную дату в календаре
        if let selectedDate = selectedDate,
           let selectionBehavior = uiView.selectionBehavior as? UICalendarSelectionSingleDate {
            let components = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
            selectionBehavior.setSelected(components, animated: true)
        }
        
        // Обновляем декораторы для дней рождения
        // Декоратор должен показываться каждый год, поэтому проверяем только день и месяц
        context.coordinator.birthdayDays = Set(profiles.map { profile in
            let calendar = Calendar.current
            let day = calendar.component(.day, from: profile.dateOfBirth)
            let month = calendar.component(.month, from: profile.dateOfBirth)
            return BirthdayDate(month: month, day: day)
        })
        
        uiView.delegate = context.coordinator
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: iOSCalendarView
        var birthdayDays: Set<BirthdayDate> = []
        
        init(_ parent: iOSCalendarView) {
            self.parent = parent
        }
        
        // MARK: - UICalendarViewDelegate
        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            guard let month = dateComponents.month,
                  let day = dateComponents.day else {
                return nil
            }
            
            // Проверяем, есть ли день рождения в этот день и месяц (любой год)
            if birthdayDays.contains(BirthdayDate(month: month, day: day)) {
                return UICalendarView.Decoration.default(color: .systemRed, size: .small)
            }
            
            return nil
        }
        
        // MARK: - UICalendarSelectionSingleDateDelegate
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            if let components = dateComponents,
               let date = Calendar.current.date(from: components) {
                parent.selectedDate = date
            } else {
                parent.selectedDate = nil
            }
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate, canSelectDate dateComponents: DateComponents?) -> Bool {
            return true
        }
    }
}
