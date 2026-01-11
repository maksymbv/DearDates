//
//  LocalizationManager.swift
//  DearDates
//
//  Created on 2026
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
        "navigation.people": "Люди",
        "navigation.calendar": "Календарь",
        "navigation.search": "Поиск",
        "navigation.settings": "Настройки",
        "navigation.profile": "Профиль",
        "navigation.edit_profile": "Редактировать профиль",
        "navigation.new_profile": "Новый профиль",
        "navigation.new_gift": "Новая идея",
        "navigation.edit_gift": "Редактировать идею",
        "navigation.gift": "Идея",
        "navigation.theme": "Тема",
        "navigation.notifications": "Уведомления",
        "navigation.event_date": "Дата события",
        "navigation.user_profile": "Мой профиль",
        // Buttons
        "button.save": "Сохранить",
        "button.cancel": "Отмена",
        "button.delete": "Удалить",
        "button.edit": "Редактировать",
        "button.add": "Добавить",
        "button.today": "Сегодня",
        "button.delete_profile": "Удалить профиль",
        "button.delete_gift": "Удалить идею",
        "button.add_event": "Добавить событие",
        "button.ok": "ОК",
        "button.touchid_authenticate": "Разблокировать",
        
        // Labels
        "label.name": "Имя",
        "label.photo": "Фото",
        "label.add_photo": "Добавить фото",
        "label.event_date": "Дата события",
        "label.notes": "Заметки",
        "label.notifications": "Уведомления",
        "label.enable_notifications": "Включить уведомления",
        "label.reminder_days_before": "За",
        "label.gift_ideas": "Идеи подарков",
        "label.gift_idea": "идея подарка",
        "label.profiles": "Профили",
        "label.gift_history": "История подарков",
        "label.statistics": "Статистика",
        "label.gift_title": "Что это будет?",
        "label.gift_description": "Опишите свою идею...",
        "label.version": "Версия",
        "label.not_selected": "Не выбрана",
        "label.theme": "Тема",
        "label.theme_system": "Системная",
        "label.theme_light": "Светлая",
        "label.theme_dark": "Темная",
        "label.accent_color": "Акцентный цвет",
        "label.color_pink": "Розовый",
        "label.color_blue": "Синий",
        "label.event_name": "Название события",
        "label.event_name_placeholder": "День рождения, Годовщина, Новый год...",
        "label.profile_name_placeholder": "Как его / её зовут",
        "label.profile_notes_placeholder": "Хобби, размер одежды и важные мелочи…",
        "label.user_profile_name_placeholder": "Ваше имя",
        "label.remind_annually": "Напоминать ежегодно",
        "label.event": "Событие",
        "label.month": "Месяц",
        "label.day": "День",
        "label.days": "дней",
        
        // Messages
        "message.delete_profile_confirm": "Удалить профиль?",
        "message.delete_profile_description": "Это действие нельзя отменить. Все данные профиля и подарки будут удалены.",
        "message.delete_gift_confirm": "Удалить подарок?",
        "message.delete_gift_description": "Это действие нельзя отменить.",
        "message.delete_event_confirm": "Удалить событие?",
        "message.delete_event_description": "Это действие нельзя отменить.",
        "message.no_gift_ideas": "Нет идей подарков",
        "message.gift_ideas_placeholder": "Тут будут ваши отличные идеи подарков",
        "message.will_turn": "исполнится",
        "message.today": "сегодня",
        "message.app_description": "Dear Dates - Место, где заботятся о близких и готовятся заранее.",
        "message.notifications_enabled_description": "Уведомления будут приходить согласно настройкам каждого профиля",
        "message.notifications_disabled": "Все уведомления отключены",
        "message.start_search": "Начните поиск",
        "message.nothing_found": "Ничего не найдено",
        "message.try_another_query": "Попробуйте другой запрос",
        "message.search_prompt": "Поиск по имени, заметкам или идеям подарков",
        "message.profile_not_found": "Профиль не найден",
        "message.no_events_today": "На сегодня событий нет",
        "message.nearest_event": "ближайшее",
        "message.add_first_event": "Добавьте первое событие",
        
        // Easter Egg
        "easteregg.title": "Маленькое письмо",
        "easteregg.message": "Привет, меня зовут Максим, я создатель Dear Dates.\n\nКак и многие, я люблю дарить радость, ловить теплые эмоции и видеть, что людям приятно. Но, к сожалению не всегда помню важные даты, даже если это близкие люди. Именно поэтому пришла идея создать приложение, которое помогает не пропускать важные даты и записывать идеи того что можно подарить в нужный момент.\n\nЯ сам пользуюсь Dear Dates и делаю его для вас так, как сделал бы для себя. Рад, что вы установили его. Даже если оно прожило в вашем телефоне недолго, я искренне благодарен - вы показали, что мои старания не зря.\n\nВпереди еще много всего интересного. Желаю вам теплых воспоминаний, радостных моментов и бесценных мгновений с близкими.\n\nС уважением,\nМаксим Баранов",
        
        // Onboarding
        "onboarding.welcome.title": "Добро пожаловать в Dear Dates",
        "onboarding.welcome.description": "Мягкий способ помнить важные события и сохранять идеи подарков для близких.",

        "onboarding.profiles.title": "Добавляйте близких",
        "onboarding.profiles.description": "Создавайте профили с событиями, фотографиями и заметками. Всё важное — в одном месте.",

        "onboarding.gifts.title": "Сохраняйте идеи подарков",
        "onboarding.gifts.description": "Записывайте идеи, когда они приходят в голову. Без спешки и стресса в последний момент.",

        "onboarding.calendar.title": "Будьте готовы заранее",
        "onboarding.calendar.description": "Смотрите предстоящие события в календаре. Напоминания помогут не забыть вовремя.",
        
        // Settings
        "settings.main": "Основные",
        "settings.other": "Остальные",
        "settings.about": "О приложении",
        "settings.data": "Данные",
        "settings.export_data": "Экспортировать данные",
        "settings.import_data": "Импортировать данные",
        "settings.report_bug": "Сообщить об ошибке",
        "settings.request_feature": "Запрос функции",
        "settings.support_email_subject": "Support email",
        "settings.request_feature_subject": "Request feature",
        
        // Sections
        "section.main_info": "Имя",
        "section.add_to_event": "Добавить к событию",
        "section.gifts_info": "Информация о подарке",
        "section.appearance": "Внешний вид",
        "section.events": "События",
        
        // Empty states
        "empty.no_profiles_title": "Тут кого-то не хватает...",
        "empty.no_profiles_message": "Добавь своего первого дорогого человека, чтобы не пропустить праздник и вовремя записать крутую идею.",
        
        // Days text
        "days.day": "день",
        "days.days_2_4": "дня",
        "days.days": "дней",
        "days.today": "сегодня",
        "days.in_1_day": "через 1 день",
        "days.in_days": "через %d %@",
        
        // Notifications
        "notification.event.title": "Событие!",
        "notification.event.body": "Сегодня событие у %@! 🎉",
        "notification.reminder.title": "Напоминание о событии",
        "notification.reminder.body": "Через %d %@ событие у %@",
        
        // Errors
        "error.title": "Ошибка",
        "error.data_save_failed": "Не удалось сохранить данные: %@",
        "error.data_load_failed": "Не удалось загрузить данные: %@",
        "error.image_save_failed": "Не удалось сохранить изображение. Проверьте доступ к хранилищу устройства.",
        "error.image_load_failed": "Не удалось загрузить изображение. Файл может быть поврежден или удален.",
        "error.notification_permission_denied": "Доступ к уведомлениям запрещен. Включите уведомления в настройках приложения, чтобы получать напоминания о событиях.",
        "error.photo_library_permission_denied": "Доступ к фотографиям запрещен. Включите доступ в настройках приложения, чтобы добавлять фото профилей.",
        "error.validation_failed": "Ошибка валидации: %@",
        
        // Validation messages
        "validation.name_empty": "Имя не может быть пустым",
        "validation.name_too_long": "Имя слишком длинное (максимум 100 символов)",
        "validation.event_date_required": "Необходимо выбрать дату события",
        "validation.event_date_future": "Дата события не может быть в будущем",
        "validation.event_date_too_old": "Дата события слишком старая",
        "validation.duplicate_profile": "Профиль с таким именем уже существует",
        
        // Accessibility
        "accessibility.profile_photo": "Фото профиля",
        "accessibility.profile_avatar": "Аватар профиля",
        "accessibility.profile_row": "Профиль",
        "accessibility.profile_row_hint": "Двойное нажатие для просмотра деталей",
        "accessibility.profile_header": "Заголовок профиля",
        "accessibility.favorite": "Избранное",
        "accessibility.add_favorite": "Добавить в избранное",
        "accessibility.remove_favorite": "Удалить из избранного",
        "accessibility.edit_profile": "Редактировать профиль",
        "accessibility.add_profile": "Добавить профиль",
        "accessibility.show_favorites": "Показать избранные",
        "accessibility.show_all_profiles": "Показать все профили",
        "accessibility.name_field": "Поле имени",
        "accessibility.name_field_hint": "Введите имя профиля",
        "accessibility.event_date_button": "Кнопка выбора даты события",
        "accessibility.event_date_button_hint": "Нажмите для выбора даты события",
        "accessibility.add_photo_button": "Кнопка добавления фото",
        "accessibility.add_photo_button_hint": "Нажмите для добавления фото профиля",
        "accessibility.add_gift": "Добавить идею подарка",
        "accessibility.gift_row": "Подарок",
        "accessibility.gift_row_hint": "Двойное нажатие для редактирования",
        "accessibility.gift_row_hint_idea": "Двойное нажатие для редактирования идеи подарка",
        "accessibility.mark_gift_given": "Отметить подарок как подаренный",
        "accessibility.user_profile_button": "Профиль пользователя",
        "accessibility.user_profile_stats": "%d профилей, %d идей подарков",
        "accessibility.appearance_settings": "Настройки внешнего вида",
        "accessibility.notifications_settings": "Настройки уведомлений",
        "accessibility.report_bug": "Сообщить об ошибке",
        "accessibility.request_feature": "Запросить функцию",
        "accessibility.export_data": "Экспортировать данные",
        "accessibility.import_data": "Импортировать данные",
        "accessibility.notes": "Заметки",
        "accessibility.no_gift_ideas": "Нет идей подарков"
    ]
    
    // MARK: - Ukrainian Strings
    private static let ukrainianStrings: [String: String] = [
        // Navigation
        "navigation.people": "Люди",
        "navigation.calendar": "Календар",
        "navigation.search": "Пошук",
        "navigation.settings": "Налаштування",
        "navigation.profile": "Профіль",
        "navigation.edit_profile": "Редагувати профіль",
        "navigation.new_profile": "Новий профіль",
        "navigation.new_gift": "Нова ідея подарунка",
        "navigation.edit_gift": "Редагувати ідею подарунка",
        "navigation.gift": "Ідея подарунка",
        "navigation.theme": "Тема",
        "navigation.notifications": "Сповіщення",
        "navigation.event_date": "Дата події",
        "navigation.user_profile": "Мій профіль",
        // Buttons
        "button.save": "Зберегти",
        "button.cancel": "Скасувати",
        "button.delete": "Видалити",
        "button.edit": "Редагувати",
        "button.add": "Додати",
        "button.today": "Сьогодні",
        "button.add_event": "Додати подію",
        "button.delete_profile": "Видалити профіль",
        "button.delete_gift": "Видалити ідею",
        "button.ok": "ОК",
        "button.touchid_authenticate": "Розблокувати",
        
        // Labels
        "label.name": "Ім'я",
        "label.photo": "Фото",
        "label.add_photo": "Додати фото",
        "label.event_date": "Дата події",
        "label.notes": "Нотатки",
        "label.notifications": "Сповіщення",
        "label.enable_notifications": "Увімкнути сповіщення",
        "label.reminder_days_before": "За",
        "label.gift_ideas": "Ідеї подарунків",
        "label.gift_idea": "ідея подарунка",
        "label.profiles": "Профілі",
        "label.gift_history": "Історія подарунків",
        "label.statistics": "Статистика",
        "label.gift_title": "Що це буде?",
        "label.gift_description": "Опишіть свою ідею...",
        "label.version": "Версія",
        "label.not_selected": "Не вибрано",
        "label.theme": "Тема",
        "label.theme_system": "Системна",
        "label.theme_light": "Світла",
        "label.theme_dark": "Темна",
        "label.accent_color": "Акцентний колір",
        "label.color_pink": "Рожевий",
        "label.color_blue": "Синій",
        "label.event_name": "Назва події",
        "label.event_name_placeholder": "День народження, Річниця, Новий рік...",
        "label.profile_name_placeholder": "Як його / її звати",
        "label.profile_notes_placeholder": "Хобі, розмір одягу та важливі дрібниці…",
        "label.user_profile_name_placeholder": "Ваше ім'я",
        "label.remind_annually": "Нагадувати щорічно",
        "label.event": "Подія",
        "label.month": "Місяць",
        "label.day": "День",
        "label.days": "днів",
        
        // Messages
        "message.delete_profile_confirm": "Видалити профіль?",
        "message.delete_profile_description": "Цю дію неможливо скасувати. Усі дані профілю та подарунки будуть видалені.",
        "message.delete_gift_confirm": "Видалити подарунок?",
        "message.delete_gift_description": "Цю дію неможливо скасувати.",
        "message.delete_event_confirm": "Видалити подію?",
        "message.delete_event_description": "Цю дію неможливо скасувати.",
        "message.no_gift_ideas": "Немає ідей подарунків",
        "message.gift_ideas_placeholder": "Тут будуть ваші чудові ідеї подарунків",
        "message.will_turn": "виповниться",
        "message.today": "сьогодні",
        "message.app_description": "Dear Dates - Місце, де піклуються про близьких і готуються заздалегідь.",
        "message.notifications_enabled_description": "Сповіщення будуть приходити згідно з налаштуваннями кожного профілю",
        "message.notifications_disabled": "Усі сповіщення вимкнено",
        "message.start_search": "Почніть пошук",
        "message.nothing_found": "Нічого не знайдено",
        "message.try_another_query": "Спробуйте інший запит",
        "message.search_prompt": "Пошук за іменем, нотатками або ідеями подарунків",
        "message.profile_not_found": "Профіль не знайдено",
        "message.no_events_today": "На сьогодні подій немає",
        "message.nearest_event": "найближче",
        "message.add_first_event": "Додайте першу подію",
        
        // Easter Egg
        "easteregg.title": "Маленький лист",
        "easteregg.message": "Привіт, мене звати Максим, я творець Dear Dates.\n\nЯк і більшість з нас, я люблю дарувати радість, ловити теплі емоції та бачити, що людям приємно. Але, на жаль, не завжди пам'ятаю важливі дати, навіть якщо це близькі люди. Саме тому виникла ідея створити додаток, який допомагає не пропускати важливі дати та записувати ідеї того, що можна подарувати у потрібний момент.\n\nЯ сам користуюсь Dear Dates і роблю його для вас так, як зробив би для себе. Радий, що ви його встановили. Навіть якщо він пробув у вашому телефоні недовго, я щиро вдячний — ви показали, що мої старання не марні.\n\nПопереду ще багато цікавого. Бажаю вам теплих спогадів, радісних моментів та безцінних миттєвостей із близькими.\n\nЗ повагою,\nМаксим Баранов",
        
        // Onboarding
        "onboarding.welcome.title": "Ласкаво просимо до Dear Dates",
        "onboarding.welcome.description": "М'який спосіб пам'ятати важливі події та зберігати ідеї подарунків для близьких.",

        "onboarding.profiles.title": "Додайте близьких",
        "onboarding.profiles.description": "Створюйте профілі з подіями, фото та нотатками. Усе важливе — в одному місці.",

        "onboarding.gifts.title": "Зберігайте ідеї подарунків",
        "onboarding.gifts.description": "Занотовуйте ідеї, коли вони з’являються. Без стресу в останню мить.",

        "onboarding.calendar.title": "Будьте готові",
        "onboarding.calendar.description": "Переглядайте майбутні події в календарі. Нагадування допоможуть не забути.",
        
        // Settings
        "settings.main": "Основні",
        "settings.other": "Інші",
        "settings.about": "Про додаток",
        "settings.data": "Дані",
        "settings.export_data": "Експортувати дані",
        "settings.import_data": "Імпортувати дані",
        "settings.report_bug": "Повідомити про помилку",
        "settings.request_feature": "Запит функції",
        "settings.support_email_subject": "Support email",
        "settings.request_feature_subject": "Request feature",
        
        // Sections
        "section.main_info": "Ім'я",
        "section.add_to_event": "Додати до події",
        "section.gifts_info": "Інформація про подарунок",
        "section.appearance": "Зовнішній вигляд",
        "section.events": "Події",
        // Empty states
        "empty.no_profiles_title": "Тут когось не вистачає...",
        "empty.no_profiles_message": "Додай свою першу важливу людину, щоб не проґавити її свято та вчасно записати круту ідею.",
        
        // Days text
        "days.day": "день",
        "days.days_2_4": "дні",
        "days.days": "днів",
        "days.today": "сьогодні",
        "days.in_1_day": "через 1 день",
        "days.in_days": "через %d %@",
        
        // Notifications
        "notification.event.title": "Подія!",
        "notification.event.body": "Сьогодні подія у %@! 🎉",
        "notification.reminder.title": "Нагадування про подію",
        "notification.reminder.body": "Через %d %@ подія у %@",
        
        // Errors
        "error.title": "Помилка",
        "error.data_save_failed": "Не вдалося зберегти дані: %@",
        "error.data_load_failed": "Не вдалося завантажити дані: %@",
        "error.image_save_failed": "Не вдалося зберегти зображення. Перевірте доступ до сховища пристрою.",
        "error.image_load_failed": "Не вдалося завантажити зображення. Файл може бути пошкоджений або видалений.",
        "error.notification_permission_denied": "Доступ до сповіщень заборонено. Увімкніть сповіщення в налаштуваннях додатку, щоб отримувати нагадування про події.",
        "error.photo_library_permission_denied": "Доступ до фотографій заборонено. Увімкніть доступ в налаштуваннях додатку, щоб додавати фото профілів.",
        "error.validation_failed": "Помилка валідації: %@",
        
        // Validation messages
        "validation.name_empty": "Ім'я не може бути порожнім",
        "validation.name_too_long": "Ім'я занадто довге (максимум 100 символів)",
        "validation.event_date_required": "Необхідно вибрати дату події",
        "validation.event_date_future": "Дата події не може бути в майбутньому",
        "validation.event_date_too_old": "Дата події занадто стара",
        "validation.duplicate_profile": "Профіль з таким ім'ям вже існує",
        
        // Accessibility
        "accessibility.profile_photo": "Фото профілю",
        "accessibility.profile_avatar": "Аватар профілю",
        "accessibility.profile_row": "Профіль",
        "accessibility.profile_row_hint": "Подвійне натискання для перегляду деталей",
        "accessibility.profile_header": "Заголовок профілю",
        "accessibility.favorite": "Обране",
        "accessibility.add_favorite": "Додати в обране",
        "accessibility.remove_favorite": "Видалити з обраного",
        "accessibility.edit_profile": "Редагувати профіль",
        "accessibility.add_profile": "Додати профіль",
        "accessibility.show_favorites": "Показати обрані",
        "accessibility.show_all_profiles": "Показати всі профілі",
        "accessibility.name_field": "Поле імені",
        "accessibility.name_field_hint": "Введіть ім'я профілю",
        "accessibility.event_date_button": "Кнопка вибору дати події",
        "accessibility.event_date_button_hint": "Натисніть для вибору дати події",
        "accessibility.add_photo_button": "Кнопка додавання фото",
        "accessibility.add_photo_button_hint": "Натисніть для додавання фото профілю",
        "accessibility.add_gift": "Додати ідею подарунка",
        "accessibility.gift_row": "Подарунок",
        "accessibility.gift_row_hint": "Подвійне натискання для редагування",
        "accessibility.gift_row_hint_idea": "Подвійне натискання для редагування ідеї подарунка",
        "accessibility.mark_gift_given": "Відзначити подарунок як подарований",
        "accessibility.user_profile_button": "Профіль користувача",
        "accessibility.user_profile_stats": "%d профілів, %d ідей подарунків",
        "accessibility.appearance_settings": "Налаштування зовнішнього вигляду",
        "accessibility.notifications_settings": "Налаштування сповіщень",
        "accessibility.report_bug": "Повідомити про помилку",
        "accessibility.request_feature": "Запит функції",
        "accessibility.export_data": "Експортувати дані",
        "accessibility.import_data": "Імпортувати дані",
        "accessibility.notes": "Нотатки",
        "accessibility.no_gift_ideas": "Немає ідей подарунків"
    ]
    
    // MARK: - English Strings
    private static let englishStrings: [String: String] = [
        // Navigation
        "navigation.people": "People",
        "navigation.calendar": "Calendar",
        "navigation.search": "Search",
        "navigation.settings": "Settings",
        "navigation.profile": "Profile",
        "navigation.edit_profile": "Edit Profile",
        "navigation.new_profile": "New Profile",
        "navigation.new_gift": "New Gift Idea",
        "navigation.edit_gift": "Edit Gift Idea",
        "navigation.gift": "Gift Idea",
        "navigation.theme": "Theme",
        "navigation.notifications": "Notifications",
        "navigation.event_date": "Event Date",
        "navigation.user_profile": "My Profile",
        // Buttons
        "button.save": "Save",
        "button.cancel": "Cancel",
        "button.delete": "Delete",
        "button.edit": "Edit",
        "button.add": "Add",
        "button.today": "Today",
        "button.add_event": "Add Event",
        "button.delete_profile": "Delete Profile",
        "button.delete_gift": "Delete Gift Idea",
        "button.ok": "OK",
        "button.touchid_authenticate": "Unlock",
        
        // Labels
        "label.name": "Name",
        "label.photo": "Photo",
        "label.add_photo": "Add Photo",
        "label.event_date": "Event Date",
        "label.notes": "Notes",
        "label.notifications": "Notifications",
        "label.enable_notifications": "Enable Notifications",
        "label.reminder_days_before": "In",
        "label.gift_ideas": "Gift Ideas",
        "label.gift_idea": "gift idea",
        "label.profiles": "Profiles",
        "label.gift_history": "Gift History",
        "label.statistics": "Statistics",
        "label.gift_title": "What will it be?",
        "label.gift_description": "Describe your idea...",
        "label.version": "Version",
        "label.not_selected": "Not Selected",
        "label.theme": "Theme",
        "label.theme_system": "System",
        "label.theme_light": "Light",
        "label.theme_dark": "Dark",
        "label.accent_color": "Accent Color",
        "label.color_pink": "Pink",
        "label.color_blue": "Blue",
        "label.event_name": "Event Name",
        "label.event_name_placeholder": "Birthday, Anniversary, New Year...",
        "label.profile_name_placeholder": "What's his / her name?",
        "label.profile_notes_placeholder": "Hobbies, clothing size, and important details…",
        "label.user_profile_name_placeholder": "Your name",
        "label.remind_annually": "Remind annually",
        "label.event": "Event",
        "label.month": "Month",
        "label.day": "Day",
        "label.days": "days",
        
        // Messages
        "message.delete_profile_confirm": "Delete Profile?",
        "message.delete_profile_description": "This action cannot be undone. All profile data and gifts will be deleted.",
        "message.delete_gift_confirm": "Delete Gift?",
        "message.delete_gift_description": "This action cannot be undone.",
        "message.delete_event_confirm": "Delete Event?",
        "message.delete_event_description": "This action cannot be undone.",
        "message.no_gift_ideas": "No gift ideas",
        "message.gift_ideas_placeholder": "Your great gift ideas will be here",
        "message.will_turn": "will turn",
        "message.today": "today",
        "message.app_description": "Dear Dates - A place to care for people and prepare in advance.",
        "message.notifications_enabled_description": "Notifications will be sent according to each profile's settings",
        "message.notifications_disabled": "All notifications are disabled",
        "message.start_search": "Start searching",
        "message.nothing_found": "Nothing found",
        "message.try_another_query": "Try another query",
        "message.search_prompt": "Search by name, notes or gift ideas",
        "message.profile_not_found": "Profile not found",
        "message.no_events_today": "No events today",
        "message.nearest_event": "nearest",
        "message.add_first_event": "Add your first event",
        
        // Easter Egg
        "easteregg.title": "A Little Letter",
        "easteregg.message": "Hello, my name is Maksym, and I am the creator of Dear Dates.\n\nLike many people, I love giving joy, catching warm emotions, and seeing people happy. But, unfortunately, I don't always remember important dates, even for the people closest to me. That's why the idea came to create an app that helps you not to miss important dates and to record ideas of what can be gifted at the right moment.\n\nI use Dear Dates myself and make it for you the way I would make it for myself. I'm glad you installed it. Even if it has been on your phone for only a short time, I am sincerely grateful — you've shown that my efforts are not in vain.\n\nThere's still a lot more ahead. I wish you warm memories, joyful moments, and priceless times with your loved ones.\n\nSincerely,\nMaksym Baranov",
        
        // Onboarding
       "onboarding.welcome.title": "Welcome to Dear Dates",
        "onboarding.welcome.description": "A gentle way to remember important events and keep gift ideas for the people you care about.",

        "onboarding.profiles.title": "Add your people",
        "onboarding.profiles.description": "Create profiles with events, photos, and notes. Everything important stays in one place.",

        "onboarding.gifts.title": "Save gift ideas",
        "onboarding.gifts.description": "Write down gift ideas when they come to mind. Be ready without last-minute stress.",

        "onboarding.calendar.title": "Stay prepared",
        "onboarding.calendar.description": "See upcoming events in a simple calendar. Gentle reminders help you remember in time.",
        
        // Settings
        "settings.main": "Main",
        "settings.other": "Other",
        "settings.about": "About",
        "settings.data": "Data",
        "settings.export_data": "Export Data",
        "settings.import_data": "Import Data",
        "settings.report_bug": "Report Bug",
        "settings.request_feature": "Request Feature",
        "settings.support_email_subject": "Support email",
        "settings.request_feature_subject": "Request feature",
        
        // Sections
        "section.main_info": "Name",
        "section.add_to_event": "Add to event",
        "section.gifts_info": "Gift Information",
        "section.appearance": "Appearance",
        "section.events": "Events",
        
        // Empty states
        "empty.no_profiles_title": "There's someone missing here...",
        "empty.no_profiles_message": "Add your first important person so you don't miss their events and can jot down a cool idea in time.",
        
        // Days text
        "days.day": "day",
        "days.days_2_4": "days",
        "days.days": "days",
        "days.today": "today",
        "days.in_1_day": "in 1 day",
        "days.in_days": "in %d %@",
        
        // Notifications
        "notification.event.title": "Event!",
        "notification.event.body": "Today is %@'s event! 🎉",
        "notification.reminder.title": "Event Reminder",
        "notification.reminder.body": "In %d %@ is %@'s event",
        
        // Errors
        "error.title": "Error",
        "error.data_save_failed": "Failed to save data: %@",
        "error.data_load_failed": "Failed to load data: %@",
        "error.image_save_failed": "Failed to save image. Please check device storage access.",
        "error.image_load_failed": "Failed to load image. The file may be corrupted or deleted.",
        "error.notification_permission_denied": "Notification access denied. Enable notifications in app settings to receive event reminders.",
        "error.photo_library_permission_denied": "Photo library access denied. Enable access in app settings to add profile photos.",
        "error.validation_failed": "Validation error: %@",
        
        // Validation messages
        "validation.name_empty": "Name cannot be empty",
        "validation.name_too_long": "Name is too long (maximum 100 characters)",
        "validation.event_date_required": "Event date is required",
        "validation.event_date_future": "Event date cannot be in the future",
        "validation.event_date_too_old": "Event date is too old",
        "validation.duplicate_profile": "Profile with this name already exists",
        
        // Accessibility
        "accessibility.profile_photo": "Profile photo",
        "accessibility.profile_avatar": "Profile avatar",
        "accessibility.profile_row": "Profile",
        "accessibility.profile_row_hint": "Double tap to view details",
        "accessibility.profile_header": "Profile header",
        "accessibility.favorite": "Favorite",
        "accessibility.add_favorite": "Add to favorites",
        "accessibility.remove_favorite": "Remove from favorites",
        "accessibility.edit_profile": "Edit profile",
        "accessibility.add_profile": "Add profile",
        "accessibility.show_favorites": "Show favorites",
        "accessibility.show_all_profiles": "Show all profiles",
        "accessibility.name_field": "Name field",
        "accessibility.name_field_hint": "Enter profile name",
        "accessibility.event_date_button": "Event date button",
        "accessibility.event_date_button_hint": "Tap to select event date",
        "accessibility.add_photo_button": "Add photo button",
        "accessibility.add_photo_button_hint": "Tap to add profile photo",
        "accessibility.add_gift": "Add gift idea",
        "accessibility.gift_row": "Gift",
        "accessibility.gift_row_hint": "Double tap to edit",
        "accessibility.gift_row_hint_idea": "Double tap to edit gift idea",
        "accessibility.mark_gift_given": "Mark gift as given",
        "accessibility.user_profile_button": "User profile",
        "accessibility.user_profile_stats": "%d profiles, %d gift ideas",
        "accessibility.appearance_settings": "Appearance settings",
        "accessibility.notifications_settings": "Notifications settings",
        "accessibility.report_bug": "Report bug",
        "accessibility.request_feature": "Request feature",
        "accessibility.export_data": "Export data",
        "accessibility.import_data": "Import data",
        "accessibility.notes": "Notes",
        "accessibility.no_gift_ideas": "No gift ideas"
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
    
    func daysUntilEventText(_ days: Int) -> String {
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
