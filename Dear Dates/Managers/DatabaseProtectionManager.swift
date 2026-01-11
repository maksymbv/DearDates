//
//  DatabaseProtectionManager.swift
//  DearDates
//
//  Created on 2026
//

import Foundation
import SwiftData

class DatabaseProtectionManager {
    static let shared = DatabaseProtectionManager()
    
    private init() {}
    
    // MARK: - File Protection для основной БД
    
    /// Настраивает File Protection для основной базы данных SwiftData
    /// Использует NSFileProtectionComplete - максимальная защита
    func setupMainDatabaseProtection() {
        guard let containerURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            AppLogger.log("Cannot find application support directory", level: .error, category: "DatabaseProtectionManager")
            return
        }
        
        // SwiftData может хранить файлы в разных местах, проверяем стандартные пути
        let possibleStoreNames = ["default.store", "default", "Model.store", "Model"]
        var foundFiles = false
        
        for storeName in possibleStoreNames {
            let storeURL = containerURL.appendingPathComponent(storeName)
            let storeShmURL = containerURL.appendingPathComponent("\(storeName)-shm")
            let storeWalURL = containerURL.appendingPathComponent("\(storeName)-wal")
            
            // Проверяем и устанавливаем защиту для существующих файлов
            if FileManager.default.fileExists(atPath: storeURL.path) {
                setFileProtection(url: storeURL, protection: .complete)
                foundFiles = true
            }
            if FileManager.default.fileExists(atPath: storeShmURL.path) {
                setFileProtection(url: storeShmURL, protection: .complete)
                foundFiles = true
            }
            if FileManager.default.fileExists(atPath: storeWalURL.path) {
                setFileProtection(url: storeWalURL, protection: .complete)
                foundFiles = true
            }
        }
        
        // Также проверяем все .store файлы в директории
        if let files = try? FileManager.default.contentsOfDirectory(at: containerURL, includingPropertiesForKeys: nil) {
            for file in files {
                if file.pathExtension == "store" || file.pathExtension == "store-shm" || file.pathExtension == "store-wal" {
                    setFileProtection(url: file, protection: .complete)
                    foundFiles = true
                }
            }
        }
        
        if foundFiles {
            AppLogger.log("Main database file protection set to NSFileProtectionComplete", level: .info, category: "DatabaseProtectionManager")
        } else {
            AppLogger.log("No database files found for protection setup", level: .warning, category: "DatabaseProtectionManager")
        }
    }
    
    /// Настраивает File Protection для snapshot уведомлений
    /// Использует NSFileProtectionCompleteUntilFirstUserAuthentication - доступно после первого разблокирования
    func setupNotificationSnapshotProtection() {
        guard let containerURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            AppLogger.log("Cannot find application support directory", level: .error, category: "DatabaseProtectionManager")
            return
        }
        
        let snapshotURL = containerURL.appendingPathComponent("notification_snapshot.json")
        
        // Устанавливаем File Protection для snapshot файла
        setFileProtection(url: snapshotURL, protection: .completeUntilFirstUserAuthentication)
        
        AppLogger.log("Notification snapshot file protection set to NSFileProtectionCompleteUntilFirstUserAuthentication", level: .info, category: "DatabaseProtectionManager")
    }
    
    private func setFileProtection(url: URL, protection: FileProtectionType) {
        guard FileManager.default.fileExists(atPath: url.path) else {
            // Файл еще не создан, создадим его с защитой позже
            return
        }
        
        do {
            let attributes: [FileAttributeKey: Any] = [
                .protectionKey: protection
            ]
            try FileManager.default.setAttributes(attributes, ofItemAtPath: url.path)
        } catch {
            AppLogger.log("Failed to set file protection for \(url.lastPathComponent): \(error.localizedDescription)", level: .error, category: "DatabaseProtectionManager")
        }
    }
    
    /// Создает файл с защитой (если он еще не существует)
    func createProtectedFile(at url: URL, protection: FileProtectionType) throws {
        let directory = url.deletingLastPathComponent()
        
        // Создаем директорию, если её нет
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        
        // Создаем пустой файл, если его нет
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil)
        }
        
        // Устанавливаем защиту
        let attributes: [FileAttributeKey: Any] = [
            .protectionKey: protection
        ]
        try FileManager.default.setAttributes(attributes, ofItemAtPath: url.path)
    }
}
