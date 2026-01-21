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
    private static var cachedStrings: [AppLanguage: [String: String]] = [:]
    
    static func string(_ key: String, language: AppLanguage) -> String {
        let strings = strings(for: language)
        return strings[key] ?? key
    }
    
    private static func strings(for language: AppLanguage) -> [String: String] {
        // Проверяем кэш
        if let cached = cachedStrings[language] {
            return cached
        }
        
        // Загружаем из JSON
        let loaded = loadStrings(for: language)
        cachedStrings[language] = loaded
        return loaded
    }
    
    private static func loadStrings(for language: AppLanguage) -> [String: String] {
        // Пробуем несколько вариантов путей
        var url: URL?
        
        // Вариант 1: с subdirectory в Bundle.main
        url = Bundle.main.url(forResource: language.rawValue, withExtension: "json", subdirectory: "Localizations")
        
        // Вариант 2: без subdirectory (если файлы в корне Bundle)
        if url == nil {
            url = Bundle.main.url(forResource: language.rawValue, withExtension: "json")
        }
        
        // Вариант 3: через Bundle(for:) (для некоторых случаев)
        if url == nil {
            let bundle = Bundle(for: LocalizationManager.self)
            url = bundle.url(forResource: language.rawValue, withExtension: "json", subdirectory: "Localizations")
        }
        
        // Вариант 4: полный путь через path с subdirectory
        if url == nil {
            if let path = Bundle.main.path(forResource: language.rawValue, ofType: "json", inDirectory: "Localizations") {
                url = URL(fileURLWithPath: path)
            }
        }
        
        // Вариант 5: полный путь без директории
        if url == nil {
            if let path = Bundle.main.path(forResource: language.rawValue, ofType: "json") {
                url = URL(fileURLWithPath: path)
            }
        }
        
        // Вариант 6: попытка найти файл в исходниках (для разработки)
        if url == nil {
            #if DEBUG
            let possiblePaths = [
                "Dear Dates/Localizations/\(language.rawValue).json",
                "Localizations/\(language.rawValue).json",
                "\(language.rawValue).json"
            ]
            
            for path in possiblePaths {
                if FileManager.default.fileExists(atPath: path) {
                    url = URL(fileURLWithPath: path)
                    break
                }
            }
            #endif
        }
        
        guard let fileURL = url else {
            print("⚠️ Localization file not found for language: \(language.rawValue)")
            print("   Please ensure that \(language.rawValue).json is:")
            print("   1. Added to the Xcode project")
            print("   2. Included in Target Membership")
            print("   3. Located in 'Localizations' folder")
            return [:]
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let strings = try decoder.decode([String: String].self, from: data)
            print("✅ Successfully loaded localization for language: \(language.rawValue) from: \(fileURL.path)")
            return strings
        } catch {
            print("⚠️ Failed to load localization for \(language.rawValue): \(error)")
            print("   File URL: \(fileURL)")
            return [:]
        }
    }
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
