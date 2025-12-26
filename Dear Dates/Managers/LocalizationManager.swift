//
//  LocalizationManager.swift
//  DearDates
//
//  Created on 2025
//

import SwiftUI
import Foundation
import Combine

enum AppLanguage: String, CaseIterable {
    case russian = "ru"
    case ukrainian = "uk"
    case english = "en"
    
    var locale: Locale {
        Locale(identifier: rawValue)
    }
}

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: AppLanguage
    
    private init() {
        // Определяем язык системы
        let systemLanguage = Locale.preferredLanguages.first?.prefix(2) ?? "en"
        
        switch systemLanguage {
        case "ru":
            currentLanguage = .russian
        case "uk":
            currentLanguage = .ukrainian
        default:
            currentLanguage = .english
        }
    }
    
    func localizedString(_ key: String) -> String {
        return LocalizedStrings.string(key, language: currentLanguage)
    }
}

// Структура для хранения всех переведенных строк
struct LocalizedStrings {
    static func string(_ key: String, language: AppLanguage) -> String {
        let strings = strings(for: language)
        return strings[key] ?? key
    }
    
    private static func strings(for language: AppLanguage) -> [String: String] {
        switch language {
        case .russian:
            return russianStrings
        case .ukrainian:
            return ukrainianStrings
        case .english:
            return englishStrings
        }
    }
    
    // MARK: - Russian Strings
    private static let russianStrings: [String: String] = [
        // Navigation
        "navigation.list": "Список",
        "navigation.calendar": "Календарь",
        "navigation.search": "Поиск",
        "navigation.settings": "Настройки",
        "navigation.profile": "Профиль",
        "navigation.edit_profile": "Редактировать профиль",
        "navigation.new_profile": "Новый профиль",
        "navigation.new_gift": "Новый подарок",
        "navigation.edit_gift": "Редактировать подарок",
        "navigation.gift": "Подарок",
        "navigation.theme": "Тема",
        "navigation.notifications": "Уведомления",
        "navigation.birth_date": "Дата рождения",
        "navigation.group": "Группа",
        "navigation.new_group": "Новая группа",
        "navigation.edit_group": "Редактировать группу",
        "navigation.select_group": "Выбрать группу",
        
        // Buttons
        "button.all": "Все",
        "button.save": "Сохранить",
        "button.cancel": "Отмена",
        "button.delete": "Удалить",
        "button.edit": "Редактировать",
        "button.add": "Добавить",
        "button.today": "Сегодня",
        "button.delete_profile": "Удалить профиль",
        "button.delete_gift": "Удалить подарок",
        "button.delete_group": "Удалить группу",
        
        // Labels
        "label.name": "Имя",
        "label.photo": "Фото",
        "label.add_photo": "Добавить фото",
        "label.birth_date": "Дата рождения",
        "label.notes": "Заметки",
        "label.group": "Группа",
        "label.no_group": "Не выбрана",
        "label.group_name": "Название группы",
        "label.no_group_option": "Без группы",
        "label.notifications": "Уведомления",
        "label.enable_notifications": "Включить уведомления",
        "label.reminder_days_before": "За",
        "label.gift_ideas": "Идеи подарков",
        "label.gift_history": "История подарков",
        "label.year": "год",
        "label.gift_title": "Название подарка",
        "label.gift_description": "Описание",
        "label.version": "Версия",
        "label.not_selected": "Не выбрана",
        "label.theme": "Тема",
        "label.theme_system": "Системная",
        "label.theme_light": "Светлая",
        "label.theme_dark": "Темная",
        "label.accent_color": "Акцентный цвет",
        "label.color_pink": "Розовый",
        "label.color_blue": "Синий",
        
        // Messages
        "message.delete_profile_confirm": "Удалить профиль?",
        "message.delete_profile_description": "Это действие нельзя отменить. Все данные профиля и подарки будут удалены.",
        "message.delete_gift_confirm": "Удалить подарок?",
        "message.delete_gift_description": "Это действие нельзя отменить.",
        "message.delete_group_confirm": "Удалить группу?",
        "message.delete_group_description": "Группа «%@» будет удалена. %d профилей будут перемещены в общую категорию.",
        "message.no_profiles": "Нет профилей в группе",
        "message.select_other_group": "Выберите другую группу или создайте новый профиль",
        "message.no_gift_ideas": "Нет идей подарков",
        "message.will_turn": "исполнится",
        "message.today": "сегодня",
        "message.app_description": "Dear Dates - приложение для отслеживания дней рождения и управления подарками",
        "message.notifications_enabled_description": "Уведомления будут приходить согласно настройкам каждого профиля",
        "message.notifications_disabled": "Все уведомления отключены",
        "message.start_search": "Начните поиск",
        "message.nothing_found": "Ничего не найдено",
        "message.try_another_query": "Попробуйте другой запрос",
        "message.search_prompt": "Поиск по имени или заметкам",
        
        // Settings
        "settings.main": "Основные",
        "settings.other": "Остальные",
        "settings.about": "О приложении",
        "settings.report_bug": "Сообщить об ошибке",
        "settings.request_feature": "Запрос функции",
        "settings.support_email_subject": "Support email",
        "settings.request_feature_subject": "Request feature",
        
        // Sections
        "section.main_info": "Основная информация",
        "section.gifts_info": "Информация о подарке",
        "section.appearance": "Внешний вид",
        
        // Empty states
        "empty.no_profiles_title": "Нет профилей",
        "empty.no_profiles_message": "Добавьте первый профиль, чтобы начать отслеживать дни рождения",
        
        // Days text
        "days.day": "день",
        "days.days_2_4": "дня",
        "days.days": "дней",
        "days.today": "сегодня",
        "days.in_1_day": "через 1 день",
        "days.in_days": "через %d %@"
    ]
    
    // MARK: - Ukrainian Strings
    private static let ukrainianStrings: [String: String] = [
        // Navigation
        "navigation.list": "Список",
        "navigation.calendar": "Календар",
        "navigation.search": "Пошук",
        "navigation.settings": "Налаштування",
        "navigation.profile": "Профіль",
        "navigation.edit_profile": "Редагувати профіль",
        "navigation.new_profile": "Новий профіль",
        "navigation.new_gift": "Новий подарунок",
        "navigation.edit_gift": "Редагувати подарунок",
        "navigation.gift": "Подарунок",
        "navigation.theme": "Тема",
        "navigation.notifications": "Сповіщення",
        "navigation.birth_date": "Дата народження",
        "navigation.group": "Група",
        "navigation.new_group": "Нова група",
        "navigation.edit_group": "Редагувати групу",
        "navigation.select_group": "Виберіть групу",
        
        // Buttons
        "button.all": "Всі",
        "button.save": "Зберегти",
        "button.cancel": "Скасувати",
        "button.delete": "Видалити",
        "button.edit": "Редагувати",
        "button.add": "Додати",
        "button.today": "Сьогодні",
        "button.delete_profile": "Видалити профіль",
        "button.delete_gift": "Видалити подарунок",
        "button.delete_group": "Видалити групу",
        
        // Labels
        "label.name": "Ім'я",
        "label.photo": "Фото",
        "label.add_photo": "Додати фото",
        "label.birth_date": "Дата народження",
        "label.notes": "Нотатки",
        "label.group": "Група",
        "label.no_group": "Не вибрано",
        "label.group_name": "Назва групи",
        "label.no_group_option": "Без групи",
        "label.notifications": "Сповіщення",
        "label.enable_notifications": "Увімкнути сповіщення",
        "label.reminder_days_before": "За",
        "label.gift_ideas": "Ідеї подарунків",
        "label.gift_history": "Історія подарунків",
        "label.year": "рік",
        "label.gift_title": "Назва подарунка",
        "label.gift_description": "Опис",
        "label.version": "Версія",
        "label.not_selected": "Не вибрано",
        "label.theme": "Тема",
        "label.theme_system": "Системна",
        "label.theme_light": "Світла",
        "label.theme_dark": "Темна",
        "label.accent_color": "Акцентний колір",
        "label.color_pink": "Рожевий",
        "label.color_blue": "Синій",
        
        // Messages
        "message.delete_profile_confirm": "Видалити профіль?",
        "message.delete_profile_description": "Цю дію неможливо скасувати. Усі дані профілю та подарунки будуть видалені.",
        "message.delete_gift_confirm": "Видалити подарунок?",
        "message.delete_gift_description": "Цю дію неможливо скасувати.",
        "message.delete_group_confirm": "Видалити групу?",
        "message.delete_group_description": "Групу «%@» буде видалено. %d профілів буде переміщено в загальну категорію.",
        "message.no_profiles": "Немає профілів у групі",
        "message.select_other_group": "Виберіть іншу групу або створіть новий профіль",
        "message.no_gift_ideas": "Немає ідей подарунків",
        "message.will_turn": "виповниться",
        "message.today": "сьогодні",
        "message.app_description": "Dear Dates - додаток для відстеження днів народження та управління подарунками",
        "message.notifications_enabled_description": "Сповіщення будуть приходити згідно з налаштуваннями кожного профілю",
        "message.notifications_disabled": "Усі сповіщення вимкнено",
        "message.start_search": "Почніть пошук",
        "message.nothing_found": "Нічого не знайдено",
        "message.try_another_query": "Спробуйте інший запит",
        "message.search_prompt": "Пошук за іменем або нотатками",
        
        // Settings
        "settings.main": "Основні",
        "settings.other": "Інші",
        "settings.about": "Про додаток",
        "settings.report_bug": "Повідомити про помилку",
        "settings.request_feature": "Запит функції",
        "settings.support_email_subject": "Support email",
        "settings.request_feature_subject": "Request feature",
        
        // Sections
        "section.main_info": "Основна інформація",
        "section.gifts_info": "Інформація про подарунок",
        "section.appearance": "Зовнішній вигляд",
        
        // Empty states
        "empty.no_profiles_title": "Немає профілів",
        "empty.no_profiles_message": "Додайте перший профіль, щоб почати відстежувати дні народження",
        
        // Days text
        "days.day": "день",
        "days.days_2_4": "дні",
        "days.days": "днів",
        "days.today": "сьогодні",
        "days.in_1_day": "через 1 день",
        "days.in_days": "через %d %@"
    ]
    
    // MARK: - English Strings
    private static let englishStrings: [String: String] = [
        // Navigation
        "navigation.list": "List",
        "navigation.calendar": "Calendar",
        "navigation.search": "Search",
        "navigation.settings": "Settings",
        "navigation.profile": "Profile",
        "navigation.edit_profile": "Edit Profile",
        "navigation.new_profile": "New Profile",
        "navigation.new_gift": "New Gift",
        "navigation.edit_gift": "Edit Gift",
        "navigation.gift": "Gift",
        "navigation.theme": "Theme",
        "navigation.notifications": "Notifications",
        "navigation.birth_date": "Birth Date",
        "navigation.group": "Group",
        "navigation.new_group": "New Group",
        "navigation.edit_group": "Edit Group",
        "navigation.select_group": "Select Group",
        
        // Buttons
        "button.all": "All",
        "button.save": "Save",
        "button.cancel": "Cancel",
        "button.delete": "Delete",
        "button.edit": "Edit",
        "button.add": "Add",
        "button.today": "Today",
        "button.delete_profile": "Delete Profile",
        "button.delete_gift": "Delete Gift",
        "button.delete_group": "Delete Group",
        
        // Labels
        "label.name": "Name",
        "label.photo": "Photo",
        "label.add_photo": "Add Photo",
        "label.birth_date": "Birth Date",
        "label.notes": "Notes",
        "label.group": "Group",
        "label.no_group": "Not Selected",
        "label.group_name": "Group Name",
        "label.no_group_option": "No Group",
        "label.notifications": "Notifications",
        "label.enable_notifications": "Enable Notifications",
        "label.reminder_days_before": "In",
        "label.gift_ideas": "Gift Ideas",
        "label.gift_history": "Gift History",
        "label.year": "year",
        "label.gift_title": "Gift Title",
        "label.gift_description": "Description",
        "label.version": "Version",
        "label.not_selected": "Not Selected",
        "label.theme": "Theme",
        "label.theme_system": "System",
        "label.theme_light": "Light",
        "label.theme_dark": "Dark",
        "label.accent_color": "Accent Color",
        "label.color_pink": "Pink",
        "label.color_blue": "Blue",
        
        // Messages
        "message.delete_profile_confirm": "Delete Profile?",
        "message.delete_profile_description": "This action cannot be undone. All profile data and gifts will be deleted.",
        "message.delete_gift_confirm": "Delete Gift?",
        "message.delete_gift_description": "This action cannot be undone.",
        "message.delete_group_confirm": "Delete Group?",
        "message.delete_group_description": "Group «%@» will be deleted. %d profiles will be moved to the general category.",
        "message.no_profiles": "No profiles in group",
        "message.select_other_group": "Select another group or create a new profile",
        "message.no_gift_ideas": "No gift ideas",
        "message.will_turn": "will turn",
        "message.today": "today",
        "message.app_description": "Dear Dates - app for tracking birthdays and managing gifts",
        "message.notifications_enabled_description": "Notifications will be sent according to each profile's settings",
        "message.notifications_disabled": "All notifications are disabled",
        "message.start_search": "Start searching",
        "message.nothing_found": "Nothing found",
        "message.try_another_query": "Try another query",
        "message.search_prompt": "Search by name or notes",
        
        // Settings
        "settings.main": "Main",
        "settings.other": "Other",
        "settings.about": "About",
        "settings.report_bug": "Report Bug",
        "settings.request_feature": "Request Feature",
        "settings.support_email_subject": "Support email",
        "settings.request_feature_subject": "Request feature",
        
        // Sections
        "section.main_info": "Main Information",
        "section.gifts_info": "Gift Information",
        "section.appearance": "Appearance",
        
        // Empty states
        "empty.no_profiles_title": "No Profiles",
        "empty.no_profiles_message": "Add your first profile to start tracking birthdays",
        
        // Days text
        "days.day": "day",
        "days.days_2_4": "days",
        "days.days": "days",
        "days.today": "today",
        "days.in_1_day": "in 1 day",
        "days.in_days": "in %d %@"
    ]
}

// MARK: - Convenience Extension
extension String {
    var localized: String {
        LocalizationManager.shared.localizedString(self)
    }
    
    func localized(_ args: CVarArg...) -> String {
        let format = LocalizationManager.shared.localizedString(self)
        return String(format: format, arguments: args)
    }
}

// MARK: - Helper Functions
extension LocalizationManager {
    func daysText(_ days: Int) -> String {
        switch currentLanguage {
        case .russian:
            if days == 1 {
                return LocalizedStrings.string("days.day", language: currentLanguage)
            } else if days >= 2 && days <= 4 {
                return LocalizedStrings.string("days.days_2_4", language: currentLanguage)
            } else {
                return LocalizedStrings.string("days.days", language: currentLanguage)
            }
        case .ukrainian:
            if days == 1 {
                return LocalizedStrings.string("days.day", language: currentLanguage)
            } else if days >= 2 && days <= 4 {
                return LocalizedStrings.string("days.days_2_4", language: currentLanguage)
            } else {
                return LocalizedStrings.string("days.days", language: currentLanguage)
            }
        case .english:
            return days == 1 ? LocalizedStrings.string("days.day", language: currentLanguage) : LocalizedStrings.string("days.days", language: currentLanguage)
        }
    }
    
    func daysUntilBirthdayText(_ days: Int) -> String {
        if days == 0 {
            return LocalizedStrings.string("days.today", language: currentLanguage)
        } else if days == 1 {
            return LocalizedStrings.string("days.in_1_day", language: currentLanguage)
        } else {
            let daysText = self.daysText(days)
            switch currentLanguage {
            case .russian:
                return "через \(days) \(daysText)"
            case .ukrainian:
                return "через \(days) \(daysText)"
            case .english:
                return "in \(days) \(daysText)"
            }
        }
    }
}
