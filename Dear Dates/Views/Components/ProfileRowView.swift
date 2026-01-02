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
    @Environment(\.colorScheme) var colorScheme
    
    let profile: Profile
    let accentColor: Color
    let locale: Locale
    
    init(profile: Profile, accentColor: Color, locale: Locale) {
        self.profile = profile
        self.accentColor = accentColor
        self.locale = locale
    }
    
    // Вычисляем следующее событие внутри компонента
    private var nextEvent: (name: String, date: Date, daysUntil: Int)? {
        // Добавляем только пользовательские события
        let profileEvents = allEvents.filter { $0.profileId == profile.id }
        
        // Сортируем по дате и возвращаем ближайшее
        return profileEvents
            .map { event in
                (name: event.name, date: event.nextDate, daysUntil: event.daysUntil)
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
            Text(profile.name)
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
        if let daysText = daysUntilText {
            Text(daysText)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(accentColor)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        }
    }
    
    @ViewBuilder
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            nameAndDaysSection
            eventInfoSection
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
        lhs.profile.photoPath == rhs.profile.photoPath
    }
}
