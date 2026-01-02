//
//  DateFormatterHelper.swift
//  DearDates
//
//  Created on 2026
//

import Foundation
import Combine

struct DateFormatterHelper {
    private static var formatterCache: [String: DateFormatter] = [:]
    private static let cacheQueue = DispatchQueue(label: "com.deardates.dateformatter.cache", attributes: .concurrent)
    
    /// Форматирует дату как "d MMMM" (например, "4 декабря")
    static func formatEventDate(_ date: Date, locale: Locale) -> String {
        let cacheKey = "event_\(locale.identifier)"
        
        return cacheQueue.sync {
            if let formatter = formatterCache[cacheKey] {
                // Форматтер уже создан с правильной локалью
                return formatter.string(from: date)
            }
            
            // Создаем новый форматтер только при первом использовании
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMMM"
            formatter.locale = locale
            formatterCache[cacheKey] = formatter
            return formatter.string(from: date)
        }
    }
    
    /// Форматирует дату в длинном формате (например, "4 декабря 2004 г.")
    static func formatLongDate(_ date: Date, locale: Locale) -> String {
        let cacheKey = "long_\(locale.identifier)"
        
        return cacheQueue.sync {
            if let formatter = formatterCache[cacheKey] {
                // Форматтер уже создан с правильной локалью
                return formatter.string(from: date)
            }
            
            // Создаем новый форматтер только при первом использовании
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.locale = locale
            formatterCache[cacheKey] = formatter
            return formatter.string(from: date)
        }
    }
    
    /// Очищает кэш форматтеров (для тестирования или при смене языка)
    static func clearCache() {
        cacheQueue.async(flags: .barrier) {
            formatterCache.removeAll()
        }
    }
}
