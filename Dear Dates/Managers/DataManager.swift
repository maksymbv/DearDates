//
//  DataManager.swift
//  DearDates
//
//  Created on 2026
//

import Foundation
import SwiftUI
import Combine
import SwiftData

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var isLoading: Bool = true
    
    private var modelContext: ModelContext?
    
    private init() {
        // Инициализация SwiftData теперь происходит через .modelContainer в App
        // Это предотвращает дублирование и позволяет миграции выполняться правильно
        isLoading = false
    }
    
    // MARK: - SwiftData Setup
    
    func setupModelContext(from container: ModelContainer) {
        // Вызывается из App после создания ModelContainer
        modelContext = ModelContext(container)
    }
    
    // MARK: - Profiles
    
    func addProfile(_ profile: Profile, context: ModelContext) {
        context.insert(profile)
        
        do {
            try context.save()
        } catch {
            let errorMessage = error.localizedDescription
            AppLogger.log("Error saving profile: \(errorMessage)", level: .error, category: "DataManager")
            ErrorManager.shared.showError(.dataSaveFailed(errorMessage))
        }
    }
    
    func updateProfile(_ profile: Profile, notificationManager: NotificationManager, context: ModelContext) {
        // ModelContext должен использоваться на главном потоке
        profile.updatedAt = Date()
        
        do {
            try context.save()
            notificationManager.updateNotifications(for: profile)
        } catch {
            let errorMessage = error.localizedDescription
            AppLogger.log("Error updating profile: \(errorMessage)", level: .error, category: "DataManager")
            ErrorManager.shared.showError(.dataSaveFailed(errorMessage))
        }
    }
    
    func togglePin(_ profile: Profile, context: ModelContext) {
        profile.isPinned.toggle()
        profile.updatedAt = Date()
        
        do {
            try context.save()
        } catch {
            let errorMessage = error.localizedDescription
            AppLogger.log("Error toggling pin: \(errorMessage)", level: .error, category: "DataManager")
            ErrorManager.shared.showError(.dataSaveFailed(errorMessage))
        }
    }
    
    func deleteProfile(_ profile: Profile, notificationManager: NotificationManager, context: ModelContext) {
        // Сохраняем данные профиля ДО удаления, чтобы избежать ошибок SwiftData
        let profileId = profile.id
        
        // Отменяем уведомления ДО удаления профиля из контекста (используем новый метод)
        notificationManager.cancelNotificationsForProfile(profileId: profileId)
        
        // Удаляем профиль из контекста
        context.delete(profile)
        
        do {
            try context.save()
        } catch {
            let errorMessage = error.localizedDescription
            AppLogger.log("Error deleting profile: \(errorMessage)", level: .error, category: "DataManager")
            ErrorManager.shared.showError(.dataSaveFailed(errorMessage))
        }
    }
    
    // MARK: - Gifts
    
    func addGift(_ gift: Gift, context: ModelContext) {
        context.insert(gift)
        
        do {
            try context.save()
        } catch {
            let errorMessage = error.localizedDescription
            AppLogger.log("Error saving gift: \(errorMessage)", level: .error, category: "DataManager")
            ErrorManager.shared.showError(.dataSaveFailed(errorMessage))
        }
    }
    
    func updateGift(_ gift: Gift, context: ModelContext) {
        // ModelContext должен использоваться на главном потоке
        gift.updatedAt = Date()
        
        do {
            try context.save()
        } catch {
            let errorMessage = error.localizedDescription
            AppLogger.log("Error updating gift: \(errorMessage)", level: .error, category: "DataManager")
            ErrorManager.shared.showError(.dataSaveFailed(errorMessage))
        }
    }
    
    func deleteGift(_ gift: Gift, context: ModelContext) {
        // ModelContext должен использоваться на главном потоке
        context.delete(gift)
        
        do {
            try context.save()
        } catch {
            let errorMessage = error.localizedDescription
            AppLogger.log("Error deleting gift: \(errorMessage)", level: .error, category: "DataManager")
            ErrorManager.shared.showError(.dataSaveFailed(errorMessage))
        }
    }
    
    func getGifts(for profileId: UUID, context: ModelContext) -> [Gift] {
        let descriptor = FetchDescriptor<Gift>(
            predicate: #Predicate { $0.profileId == profileId }
        )
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func getGivenGifts(for profileId: UUID, context: ModelContext) -> [Gift] {
        getGifts(for: profileId, context: context).filter { $0.isGiven }
    }
    
    func getGiftIdeas(for profileId: UUID, context: ModelContext) -> [Gift] {
        getGifts(for: profileId, context: context).filter { !$0.isGiven }
    }
    
    // MARK: - Data Loading
    
    
    // MARK: - Statistics
    
    func getTotalProfilesCount(context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<Profile>()
        return (try? context.fetch(descriptor).count) ?? 0
    }
    
    func getTotalGiftIdeasCount(context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<Gift>(
            predicate: #Predicate { !$0.isGiven }
        )
        return (try? context.fetch(descriptor).count) ?? 0
    }
    
    // MARK: - Export/Import
    
    func exportData(context: ModelContext) -> Data? {
        let profilesDescriptor = FetchDescriptor<Profile>()
        let profiles = (try? context.fetch(profilesDescriptor)) ?? []
        
        let giftsDescriptor = FetchDescriptor<Gift>()
        let gifts = (try? context.fetch(giftsDescriptor)) ?? []
        
        return DataExportManager.shared.exportData(
            profiles: profiles,
            gifts: gifts
        )
    }
    
    func exportToFile(context: ModelContext) -> URL? {
        let profilesDescriptor = FetchDescriptor<Profile>()
        let profiles = (try? context.fetch(profilesDescriptor)) ?? []
        
        let giftsDescriptor = FetchDescriptor<Gift>()
        let gifts = (try? context.fetch(giftsDescriptor)) ?? []
        
        return DataExportManager.shared.exportToFile(
            profiles: profiles,
            gifts: gifts
        )
    }
    
    // MARK: - Delete All Data
    
    func deleteAllData(context: ModelContext, notificationManager: NotificationManager) -> Bool {
        // Отменяем все уведомления
        notificationManager.cancelAllNotifications()
        
        // Удаляем все профили (это автоматически удалит связанные подарки и события через cascade delete)
        let profilesDescriptor = FetchDescriptor<Profile>()
        guard let profiles = try? context.fetch(profilesDescriptor) else {
            return false
        }
        
        for profile in profiles {
            // Отменяем уведомления для каждого профиля перед удалением
            notificationManager.cancelNotificationsForProfile(profileId: profile.id)
            context.delete(profile)
        }
        
        // Удаляем все подарки (каскад при удалении профиля может не сработать)
        let giftsDescriptor = FetchDescriptor<Gift>()
        if let gifts = try? context.fetch(giftsDescriptor) {
            for gift in gifts {
                context.delete(gift)
            }
        }
        
        // Удаляем все события (на случай, если что-то осталось)
        let eventsDescriptor = FetchDescriptor<CustomEvent>()
        if let events = try? context.fetch(eventsDescriptor) {
            for event in events {
                context.delete(event)
            }
        }
        
        // Сохраняем изменения
        do {
            try context.save()
            AppLogger.log("All data deleted successfully", level: .info, category: "DataManager")
            return true
        } catch {
            let errorMessage = error.localizedDescription
            AppLogger.log("Error deleting all data: \(errorMessage)", level: .error, category: "DataManager")
            ErrorManager.shared.showError(.dataSaveFailed(errorMessage))
            return false
        }
    }
    
    #if DEBUG
    // MARK: - Test Data Generation
    
    func generateTestProfilesRussian(context: ModelContext) {
        let calendar = Calendar.current
        let today = Date()
        
        struct RUProfileData {
            let name: String
            let notes: String
            let pinned: Bool
            let events: [(name: String, month: Int, day: Int)]
            let giftIdeas: [(title: String, notes: String)]
        }
        
        let profiles: [RUProfileData] = [
            RUProfileData(
                name: "Анечка ❤️",
                notes: "Любит минимализм и кофе на фундучном молоке.",
                pinned: true,
                events: [
                    ("День рождения", 5, 12),
                    ("День святого Валентина", 2, 14),
                    ("8 марта", 3, 8)
                ],
                giftIdeas: [
                    ("Instax Mini (белый)", "Чтобы сохранять ваши общие моменты в печати."),
                    ("Абонемент на йогу", "Она давно хотела попробовать студию рядом с домом.")
                ]
            ),
            RUProfileData(
                name: "Максим",
                notes: "Вместе играете в сквош по субботам. Ценит практичный юмор.",
                pinned: false,
                events: [
                    ("День рождения", 8, 20),
                    ("День ангела", 11, 17),
                    ("День дружбы", 6, 9)
                ],
                giftIdeas: [
                    ("Механическая клавиатура", "Он жаловался на свою старую во время игры."),
                    ("Билеты на стендап", "Чтобы развеяться после рабочей недели.")
                ]
            ),
            RUProfileData(
                name: "Мама",
                notes: "Обожает свой сад, детективные сериалы и книги.",
                pinned: true,
                events: [
                    ("День рождения", 4, 3),
                    ("День матери", 5, 12),
                    ("8 марта", 3, 8)
                ],
                giftIdeas: [
                    ("Умный сад (Click & Grow)", "Чтобы выращивать базилик прямо на кухне."),
                    ("Тёплый плед", "Большой, мягкий, для уютных вечеров.")
                ]
            ),
            RUProfileData(
                name: "Папа",
                notes: "Увлекается историей и любит чинить всё в гараже.",
                pinned: false,
                events: [
                    ("День рождения", 11, 15),
                    ("День отца", 6, 16),
                    ("23 февраля", 2, 23)
                ],
                giftIdeas: [
                    ("Набор инструментов Bosch", "Компактный кейс для домашних дел."),
                    ("Книга-биография Черчилля", "У него есть первая часть, нужна вторая.")
                ]
            ),
            RUProfileData(
                name: "Дмитрий",
                notes: "Работает с вами над одним проектом. Любит настольные игры.",
                pinned: false,
                events: [
                    ("День рождения", 1, 10),
                    ("Профессиональный праздник", 9, 1),
                    ("День программиста", 9, 13)
                ],
                giftIdeas: [
                    ("Стильная термокружка", "Чтобы кофе не остывал во время созвонов."),
                    ("Игра «Взрывные котята»", "Для вечеринок после работы.")
                ]
            ),
            RUProfileData(
                name: "Сестричка Юля",
                notes: "Учится на дизайнера, постоянно рисует.",
                pinned: false,
                events: [
                    ("День рождения", 9, 22),
                    ("Выпускной", 6, 30),
                    ("День сестры", 8, 2)
                ],
                giftIdeas: [
                    ("Графический планшет", "Начального уровня для её иллюстраций."),
                    ("Скетчбук с качественной бумагой", "Бумаги много не бывает.")
                ]
            ),
            RUProfileData(
                name: "Андрей",
                notes: "Переехал в новую квартиру. Любит готовить.",
                pinned: false,
                events: [
                    ("День рождения", 7, 5),
                    ("Новоселье", 12, 12),
                    ("День повара", 10, 20)
                ],
                giftIdeas: [
                    ("Набор ножей шеф-повара", "Для его кулинарных экспериментов."),
                    ("Сертификат в WineTime", "Выберет себе вино на новоселье.")
                ]
            ),
            RUProfileData(
                name: "Катя",
                notes: "Увлекается фотографией и путешествиями.",
                pinned: false,
                events: [
                    ("День рождения", 3, 18),
                    ("День дружбы", 6, 9),
                    ("День фотографа", 8, 12)
                ],
                giftIdeas: [
                    ("Объектив для камеры", "Широкоугольный для пейзажей."),
                    ("Подписка на National Geographic", "Для вдохновения.")
                ]
            ),
            RUProfileData(
                name: "Сергей",
                notes: "Помогает с организацией проектов. Любит кофе.",
                pinned: false,
                events: [
                    ("День рождения", 10, 25),
                    ("День работника", 5, 1),
                    ("День кофе", 10, 1)
                ],
                giftIdeas: [
                    ("Кофеварка V60", "Для идеального кофе дома."),
                    ("Блокнот Moleskine", "Для записей и планов.")
                ]
            ),
            RUProfileData(
                name: "Тётя Наталья",
                notes: "Учительница в школе. Обожает читать и вязать.",
                pinned: false,
                events: [
                    ("День рождения", 2, 8),
                    ("День учителя", 10, 1),
                    ("День книги", 4, 23)
                ],
                giftIdeas: [
                    ("Набор качественной пряжи", "Для её вязаных изделий."),
                    ("Книга от любимого автора", "Новый роман для вечернего чтения.")
                ]
            )
        ]
        
        for data in profiles {
            let profile = Profile(
                name: data.name,
                notes: data.notes,
                notificationsEnabled: true,
                reminderDays: [7, 1],
                isPinned: data.pinned
            )
            context.insert(profile)
            
            var firstEventId: UUID?
            for eventInfo in data.events {
                let event = CustomEvent(
                    profileId: profile.id,
                    name: eventInfo.name,
                    month: eventInfo.month,
                    day: eventInfo.day,
                    remindAnnually: true
                )
                context.insert(event)
                if firstEventId == nil { firstEventId = event.id }
            }
            
            for giftInfo in data.giftIdeas {
                let gift = Gift(
                    profileId: profile.id,
                    title: giftInfo.title,
                    notes: giftInfo.notes,
                    isGiven: false,
                    eventId: firstEventId
                )
                context.insert(gift)
            }
            
            let givenYear = calendar.component(.year, from: today) - 1
            let givenGift = Gift(
                profileId: profile.id,
                title: "Подарок в прошлом году",
                notes: "Уже подарено.",
                isGiven: true,
                givenYear: givenYear
            )
            context.insert(givenGift)
        }
        
        do {
            try context.save()
            AppLogger.log("Russian test profiles generated successfully", level: .info, category: "DataManager")
        } catch {
            let errorMessage = error.localizedDescription
            AppLogger.log("Error generating Russian test profiles: \(errorMessage)", level: .error, category: "DataManager")
            ErrorManager.shared.showError(.dataSaveFailed(errorMessage))
        }
    }
    
    func generateTestProfilesEnglish(context: ModelContext) {
        let calendar = Calendar.current
        let today = Date()
        
        struct ENProfileData {
            let name: String
            let notes: String
            let pinned: Bool
            let events: [(name: String, month: Int, day: Int)]
            let giftIdeas: [(title: String, notes: String)]
        }
        
        let profiles: [ENProfileData] = [
            ENProfileData(
                name: "Annie ❤️",
                notes: "Loves minimalism and hazelnut latte.",
                pinned: true,
                events: [
                    ("Birthday", 5, 12),
                    ("Valentine's Day", 2, 14),
                    ("International Women's Day", 3, 8)
                ],
                giftIdeas: [
                    ("Instax Mini (white)", "To keep your shared moments in print."),
                    ("Yoga studio pass", "She's been wanting to try the one near home.")
                ]
            ),
            ENProfileData(
                name: "Max",
                notes: "You play squash together on Saturdays. Loves dry humor.",
                pinned: false,
                events: [
                    ("Birthday", 8, 20),
                    ("Name day", 11, 17),
                    ("Friendship Day", 6, 9)
                ],
                giftIdeas: [
                    ("Mechanical keyboard", "He's been complaining about his old one during games."),
                    ("Stand-up comedy tickets", "To unwind after the work week.")
                ]
            ),
            ENProfileData(
                name: "Mom",
                notes: "Loves her garden, detective shows and books.",
                pinned: true,
                events: [
                    ("Birthday", 4, 3),
                    ("Mother's Day", 5, 12),
                    ("International Women's Day", 3, 8)
                ],
                giftIdeas: [
                    ("Smart garden (Click & Grow)", "To grow basil right in the kitchen."),
                    ("Cozy throw blanket", "Big and soft for cozy evenings.")
                ]
            ),
            ENProfileData(
                name: "Dad",
                notes: "Into history and fixing things in the garage.",
                pinned: false,
                events: [
                    ("Birthday", 11, 15),
                    ("Father's Day", 6, 16),
                    ("Veterans Day", 11, 11)
                ],
                giftIdeas: [
                    ("Bosch tool set", "Compact case for home repairs."),
                    ("Churchill biography", "Book. He has the first volume, needs the second.")
                ]
            ),
            ENProfileData(
                name: "Tom",
                notes: "Works on the same project. Loves board games.",
                pinned: false,
                events: [
                    ("Birthday", 1, 10),
                    ("Work anniversary", 9, 1),
                    ("Programmer's Day", 9, 13)
                ],
                giftIdeas: [
                    ("Stylish thermos", "So coffee doesn't go cold during calls."),
                    ("Exploding Kittens game", "For after-work game nights.")
                ]
            ),
            ENProfileData(
                name: "Sis Sarah",
                notes: "Studying design, always drawing and sketching.",
                pinned: false,
                events: [
                    ("Birthday", 9, 22),
                    ("Graduation", 6, 30),
                    ("Sister's Day", 8, 2)
                ],
                giftIdeas: [
                    ("Drawing tablet", "Entry-level for her illustrations."),
                    ("Quality paper sketchbook", "You can never have too much paper.")
                ]
            ),
            ENProfileData(
                name: "James",
                notes: "Just moved to a new apartment. Loves cooking.",
                pinned: false,
                events: [
                    ("Birthday", 7, 5),
                    ("Housewarming", 12, 12),
                    ("Chef's Day", 10, 20)
                ],
                giftIdeas: [
                    ("Chef's knife set", "For his kitchen experiments."),
                    ("Wine shop gift card", "To pick something for the new place.")
                ]
            ),
            ENProfileData(
                name: "Emma",
                notes: "Passionate about photography and travel.",
                pinned: false,
                events: [
                    ("Birthday", 3, 18),
                    ("Friendship Day", 6, 9),
                    ("Photography Day", 8, 12)
                ],
                giftIdeas: [
                    ("Camera lens", "Wide-angle for landscapes."),
                    ("National Geographic subscription", "For inspiration.")
                ]
            ),
            ENProfileData(
                name: "Steve",
                notes: "Helps with project organization. Coffee enthusiast.",
                pinned: false,
                events: [
                    ("Birthday", 10, 25),
                    ("Labor Day", 5, 1),
                    ("Coffee Day", 10, 1)
                ],
                giftIdeas: [
                    ("V60 pour-over set", "For perfect coffee at home."),
                    ("Moleskine notebook", "For notes and planning.")
                ]
            ),
            ENProfileData(
                name: "Aunt Mary",
                notes: "School teacher. Loves reading and knitting.",
                pinned: false,
                events: [
                    ("Birthday", 2, 8),
                    ("Teacher's Day", 10, 1),
                    ("World Book Day", 4, 23)
                ],
                giftIdeas: [
                    ("Quality yarn set", "For her knitting projects."),
                    ("Book by her favorite author", "New novel for evening reading.")
                ]
            )
        ]
        
        for data in profiles {
            let profile = Profile(
                name: data.name,
                notes: data.notes,
                notificationsEnabled: true,
                reminderDays: [7, 1],
                isPinned: data.pinned
            )
            context.insert(profile)
            
            var firstEventId: UUID?
            for eventInfo in data.events {
                let event = CustomEvent(
                    profileId: profile.id,
                    name: eventInfo.name,
                    month: eventInfo.month,
                    day: eventInfo.day,
                    remindAnnually: true
                )
                context.insert(event)
                if firstEventId == nil { firstEventId = event.id }
            }
            
            for giftInfo in data.giftIdeas {
                let gift = Gift(
                    profileId: profile.id,
                    title: giftInfo.title,
                    notes: giftInfo.notes,
                    isGiven: false,
                    eventId: firstEventId
                )
                context.insert(gift)
            }
            
            let givenYear = calendar.component(.year, from: today) - 1
            let givenGift = Gift(
                profileId: profile.id,
                title: "Last year's gift",
                notes: "Already given.",
                isGiven: true,
                givenYear: givenYear
            )
            context.insert(givenGift)
        }
        
        do {
            try context.save()
            AppLogger.log("English test profiles generated successfully", level: .info, category: "DataManager")
        } catch {
            let errorMessage = error.localizedDescription
            AppLogger.log("Error generating English test profiles: \(errorMessage)", level: .error, category: "DataManager")
            ErrorManager.shared.showError(.dataSaveFailed(errorMessage))
        }
    }
    
    func generateTestProfilesUkrainian(context: ModelContext) {
        let calendar = Calendar.current
        let today = Date()
        
        struct UAProfileData {
            let name: String
            let notes: String
            let pinned: Bool
            let events: [(name: String, month: Int, day: Int)]
            let giftIdeas: [(title: String, notes: String)]
        }
        
        let profiles: [UAProfileData] = [
            UAProfileData(
                name: "Оленка ❤️",
                notes: "Любить мінімалізм та каву на фундуковому молоці.",
                pinned: true,
                events: [
                    ("День народження", 5, 12),
                    ("Річниця", 2, 14),
                    ("8 березня", 3, 8)
                ],
                giftIdeas: [
                    ("Instax Mini (білий)", "Щоб зберігати ваші спільні моменти фізично."),
                    ("Абонемент на йогу", "Вона давно хотіла спробувати студію біля дому.")
                ]
            ),
            UAProfileData(
                name: "Максим",
                notes: "Разом граєте в сквош по суботах. Цінує практичний гумор.",
                pinned: false,
                events: [
                    ("День народження", 8, 20),
                    ("День ангела", 11, 17),
                    ("День дружби", 6, 9)
                ],
                giftIdeas: [
                    ("Механічна клавіатура", "Він скаржився на свою стару під час гри."),
                    ("Квитки на стендап", "Щоб розвіятися після робочого тижня.")
                ]
            ),
            UAProfileData(
                name: "Мама",
                notes: "Обожнює свій сад, детективні серіали та книги.",
                pinned: true,
                events: [
                    ("День народження", 4, 3),
                    ("День матері", 5, 12), // умовна дата в травні
                    ("8 березня", 3, 8)
                ],
                giftIdeas: [
                    ("Розумний сад (Click & Grow)", "Щоб вирощувати базилік прямо на кухні."),
                    ("Теплий плед", "Великий, м'який, для затишних вечорів.")
                ]
            ),
            UAProfileData(
                name: "Тато",
                notes: "Цікавиться історією та любить лагодити все в гаражі.",
                pinned: false,
                events: [
                    ("День народження", 11, 15),
                    ("День батька", 6, 16), // умовна дата в червні
                    ("23 лютого", 2, 23)
                ],
                giftIdeas: [
                    ("Набір інструментів Bosch", "Компактний кейс для домашніх справ."),
                    ("Книга-біографія Черчилля", "У нього є перша частина, потрібна друга.")
                ]
            ),
            UAProfileData(
                name: "Дмитро",
                notes: "Працює з вами над одним проєктом. Любить настільні ігри.",
                pinned: false,
                events: [
                    ("День народження", 1, 10),
                    ("Професійне свято", 9, 1), // умовна дата
                    ("День програміста", 9, 13)
                ],
                giftIdeas: [
                    ("Стильна термокружка", "Щоб кава не стигла під час мітингів."),
                    ("Гра \"Вибухові кошенята\"", "Для вечірок після роботи.")
                ]
            ),
            UAProfileData(
                name: "Сестричка Юля",
                notes: "Вчиться на дизайнера, постійно малює.",
                pinned: false,
                events: [
                    ("День народження", 9, 22),
                    ("Випускний", 6, 30),
                    ("День сестри", 8, 2)
                ],
                giftIdeas: [
                    ("Графічний планшет", "Початкового рівня для її ілюстрацій."),
                    ("Скетчбук з якісним папером", "Паперу ніколи не буває багато.")
                ]
            ),
            UAProfileData(
                name: "Андрій",
                notes: "Переїхав у нову квартиру. Любить готувати.",
                pinned: false,
                events: [
                    ("День народження", 7, 5),
                    ("Новосілля", 12, 12),
                    ("День кухаря", 10, 20)
                ],
                giftIdeas: [
                    ("Набір ножів шеф-кухаря", "Для його кулінарних експериментів."),
                    ("Сертифікат у WineTime", "Вибере собі вино на новосілля.")
                ]
            ),
            UAProfileData(
                name: "Катя",
                notes: "Захоплюється фотографією та подорожами.",
                pinned: false,
                events: [
                    ("День народження", 3, 18),
                    ("День дружби", 6, 9), // умовна дата
                    ("День фотографа", 8, 12)
                ],
                giftIdeas: [
                    ("Об'єктив для камери", "Ширококутний для пейзажів."),
                    ("Підписка на National Geographic", "Для натхнення.")
                ]
            ),
            UAProfileData(
                name: "Сергій",
                notes: "Допомагає з організацією проєктів. Любить каву.",
                pinned: false,
                events: [
                    ("День народження", 10, 25),
                    ("День працівника", 5, 1),
                    ("День кави", 10, 1)
                ],
                giftIdeas: [
                    ("Кавоварка V60", "Для ідеальної кави вдома."),
                    ("Блокнот Moleskine", "Для записів та планів.")
                ]
            ),
            UAProfileData(
                name: "Тітка Наталія",
                notes: "Вчителька у школі. Обожнює читати та в'язати.",
                pinned: false,
                events: [
                    ("День народження", 2, 8),
                    ("День вчителя", 10, 1),
                    ("День книги", 4, 23)
                ],
                giftIdeas: [
                    ("Набір якісної пряжі", "Для її в'язаних виробів."),
                    ("Книга від улюбленого автора", "Новий роман для вечірнього читання.")
                ]
            )
        ]
        
        for data in profiles {
            let profile = Profile(
                name: data.name,
                notes: data.notes,
                notificationsEnabled: true,
                reminderDays: [7, 1],
                isPinned: data.pinned
            )
            context.insert(profile)
            
            // События
            var firstEventId: UUID?
            for eventInfo in data.events {
                let event = CustomEvent(
                    profileId: profile.id,
                    name: eventInfo.name,
                    month: eventInfo.month,
                    day: eventInfo.day,
                    remindAnnually: true
                )
                context.insert(event)
                if firstEventId == nil { firstEventId = event.id }
            }
            
            // Идеи подарков (по одному разу, привязаны к первому событию)
            for giftInfo in data.giftIdeas {
                let gift = Gift(
                    profileId: profile.id,
                    title: giftInfo.title,
                    notes: giftInfo.notes,
                    isGiven: false,
                    eventId: firstEventId
                )
                context.insert(gift)
            }
            
            // Один подаренный подарок в прошлом
            let givenYear = calendar.component(.year, from: today) - 1
            let givenGift = Gift(
                profileId: profile.id,
                title: "Подарунок з минулого року",
                notes: "Вже подаровано.",
                isGiven: true,
                givenYear: givenYear
            )
            context.insert(givenGift)
        }
        
        do {
            try context.save()
            AppLogger.log("Ukrainian test profiles generated successfully", level: .info, category: "DataManager")
        } catch {
            let errorMessage = error.localizedDescription
            AppLogger.log("Error generating Ukrainian test profiles: \(errorMessage)", level: .error, category: "DataManager")
            ErrorManager.shared.showError(.dataSaveFailed(errorMessage))
        }
    }
    #endif
}
