//
//  ProfileRowView.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI
import SwiftData

struct ProfileRowView: View {
    @Query private var allEvents: [CustomEvent]
    
    @EnvironmentObject var imageManager: ImageManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    
    let profile: Profile
    let locale: Locale
    let searchText: String?
    
    init(profile: Profile, locale: Locale, searchText: String? = nil) {
        self.profile = profile
        self.locale = locale
        self.searchText = searchText
    }
    
    private var accentColor: Color {
        settingsManager.accentColor.color
    }
    
    // Вычисляем следующее событие внутри компонента
    private var nextEvent: (name: String, date: Date, daysUntil: Int, isToday: Bool)? {
        // Добавляем только пользовательские события
        let profileEvents = allEvents.filter { $0.profileId == profile.id }
        
        // Сортируем по дате и возвращаем ближайшее (сегодня имеет приоритет)
        let todayEvents = profileEvents.filter { $0.isToday }
        if let todayEvent = todayEvents.first {
            return (name: todayEvent.name, date: todayEvent.nextDate, daysUntil: todayEvent.daysUntil, isToday: true)
        }
        
        return profileEvents
            .map { event in
                (name: event.name, date: event.nextDate, daysUntil: event.daysUntil, isToday: event.isToday)
            }
            .sorted { $0.date < $1.date }
            .first
    }
    
    private var avatarImage: UIImage? {
        guard let photoPath = profile.photoPath else { return nil }
        return imageManager.loadImage(from: photoPath)
    }
    
    private var formattedEventDate: String? {
        guard let event = nextEvent else {
            return nil
        }
        return DateFormatterHelper.formatEventDate(event.date, locale: locale)
    }
    
    private var eventName: String? {
        nextEvent?.name
    }
    
    private var daysUntilText: String? {
        guard let event = nextEvent, event.daysUntil <= 30 else { return nil }
        // Используем локализацию для дней до события
        return localizationManager.daysUntilEventText(event.daysUntil)
    }
    
    private var accessibilityLabelText: String {
        var parts = ["accessibility.profile_row".localized + " \(profile.name)"]
        if let eventName = eventName, let formattedDate = formattedEventDate {
            parts.append("\(eventName) · \(formattedDate)")
        } else if let formattedDate = formattedEventDate {
            parts.append(formattedDate)
        }
        if let daysText = daysUntilText {
            parts.append(daysText)
        }
        return parts.joined(separator: ", ")
    }
    
    @ViewBuilder
    private var avatarSection: some View {
            AvatarView(
                image: avatarImage,
                name: profile.name,
                avatarColorHue: profile.avatarColorHue,
                size: 60
            )
    }
            
    @ViewBuilder
    private var nameAndDaysSection: some View {
        HStack(spacing: 8) {
            HighlightedText(
                profile.name,
                searchText: searchText ?? "",
                highlightColor: accentColor
            )
            .font(.headline)
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            
            // Звездочка рядом с именем
            if profile.isFavorite {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(accentColor)
                    .accessibilityLabel("accessibility.favorite".localized)
            }
        }
    }
    
    @ViewBuilder
    private var eventInfoSection: some View {
        if let eventName = eventName, let formattedDate = formattedEventDate {
            Text("\(eventName) · \(formattedDate)")
                .font(.caption)
                .foregroundColor(.secondary)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        } else if let formattedDate = formattedEventDate {
            Text(formattedDate)
                .font(.caption)
                .foregroundColor(.secondary)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        }
    }
    
    @ViewBuilder
    private var daysUntilSection: some View {
        if let event = nextEvent, event.isToday {
            // Бейджик "сегодня" в том же стиле, что и "через N дней"
            Text("message.today".localized)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(accentColor)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        } else if let daysText = daysUntilText {
            Text(daysText)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(accentColor)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        }
    }
    
    @ViewBuilder
    private var notesSection: some View {
        if let searchText = searchText,
           !searchText.isEmpty,
           !profile.notes.isEmpty,
           profile.notes.lowercased().contains(searchText.lowercased()) {
            HighlightedText(
                profile.notes,
                searchText: searchText,
                highlightColor: accentColor
            )
            .font(.caption)
            .foregroundColor(.secondary)
            .lineLimit(2)
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        }
    }
    
    @ViewBuilder
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            nameAndDaysSection
            eventInfoSection
            notesSection
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            avatarSection
            
            HStack(spacing: 0) {
                infoSection
                
                Spacer(minLength: 0)
                
                // Дни до события посередине по высоте, максимально справа
                daysUntilSection
                    .frame(maxHeight: .infinity, alignment: .center)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabelText)
        .accessibilityHint("accessibility.profile_row_hint".localized)
    }
}

extension ProfileRowView: Equatable {
    static func == (lhs: ProfileRowView, rhs: ProfileRowView) -> Bool {
        lhs.profile.id == rhs.profile.id &&
        lhs.profile.name == rhs.profile.name &&
        lhs.profile.isFavorite == rhs.profile.isFavorite &&
        lhs.profile.photoPath == rhs.profile.photoPath &&
        lhs.profile.notes == rhs.profile.notes &&
        lhs.searchText == rhs.searchText
    }
}
