//
//  NotificationSnapshotManager.swift
//  DearDates
//
//  Created on 2026
//

import Foundation

/// Минимальная структура данных для уведомлений
struct NotificationSnapshotItem: Codable {
    let eventId: UUID
    let profileId: UUID
    let eventName: String
    let notificationDate: Date
    let reminderDays: Int
}

/// Менеджер для работы со snapshot уведомлений
/// Хранит минимальные данные (дата, title, body) отдельно от основной БД
/// Использует NSFileProtectionCompleteUntilFirstUserAuthentication для работы уведомлений
class NotificationSnapshotManager {
    static let shared = NotificationSnapshotManager()
    
    private let snapshotURL: URL
    
    private init() {
        guard let containerURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            fatalError("Cannot find application support directory")
        }
        self.snapshotURL = containerURL.appendingPathComponent("notification_snapshot.json")
        
        // Настраиваем защиту файла
        DatabaseProtectionManager.shared.setupNotificationSnapshotProtection()
    }
    
    // MARK: - Чтение и запись
    
    /// Загружает snapshot уведомлений
    private func loadSnapshot() -> [NotificationSnapshotItem] {
        guard FileManager.default.fileExists(atPath: snapshotURL.path) else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: snapshotURL)
            let items = try JSONDecoder().decode([NotificationSnapshotItem].self, from: data)
            return items
        } catch {
            AppLogger.log("Failed to load notification snapshot: \(error.localizedDescription)", level: .error, category: "NotificationSnapshotManager")
            return []
        }
    }
    
    /// Сохраняет snapshot уведомлений
    private func saveSnapshot(_ items: [NotificationSnapshotItem]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(items)
            try data.write(to: snapshotURL)
            
            // Убеждаемся, что файл защищен
            DatabaseProtectionManager.shared.setupNotificationSnapshotProtection()
        } catch {
            AppLogger.log("Failed to save notification snapshot: \(error.localizedDescription)", level: .error, category: "NotificationSnapshotManager")
        }
    }
    
    // MARK: - Публичные методы
    
    /// Добавляет элемент в snapshot
    func addItem(_ item: NotificationSnapshotItem) {
        var items = loadSnapshot()
        
        // Удаляем старые элементы для этого события
        items.removeAll { $0.eventId == item.eventId && $0.reminderDays == item.reminderDays }
        
        // Добавляем новый элемент
        items.append(item)
        
        saveSnapshot(items)
    }
    
    /// Удаляет элементы для события
    func removeItems(forEventId eventId: UUID) {
        var items = loadSnapshot()
        items.removeAll { $0.eventId == eventId }
        saveSnapshot(items)
    }
    
    /// Удаляет элементы для профиля
    func removeItems(forProfileId profileId: UUID) {
        var items = loadSnapshot()
        items.removeAll { $0.profileId == profileId }
        saveSnapshot(items)
    }
    
    /// Получает все элементы snapshot
    func getAllItems() -> [NotificationSnapshotItem] {
        return loadSnapshot()
    }
    
    /// Получает элементы для события
    func getItems(forEventId eventId: UUID) -> [NotificationSnapshotItem] {
        return loadSnapshot().filter { $0.eventId == eventId }
    }
    
    /// Получает элементы для профиля
    func getItems(forProfileId profileId: UUID) -> [NotificationSnapshotItem] {
        return loadSnapshot().filter { $0.profileId == profileId }
    }
    
    /// Очищает весь snapshot
    func clearAll() {
        saveSnapshot([])
    }
}
