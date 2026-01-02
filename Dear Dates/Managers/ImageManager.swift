//
//  ImageManager.swift
//  DearDates
//
//  Created on 2026
//

import Foundation
import SwiftUI
import UIKit
import Combine

class ImageManager: ObservableObject {
    static let shared = ImageManager()
    
    private let documentsPath: URL
    private let imageCache: NSCache<NSString, UIImage>
    private let cacheQueue = DispatchQueue(label: "com.deardates.imagemanager.cache", attributes: .concurrent)
    
    // Максимальное количество изображений в кэше (30 изображений)
    private let maxCacheCount = 30
    // Максимальный размер кэша в байтах (15 MB вместо 50 MB)
    private let maxCacheSize: Int = 15 * 1024 * 1024
    
    // Максимальный размер изображения для сохранения (500x500 пикселей)
    private let maxImageSize: CGFloat = 500
    
    // Количество дней для автоматической очистки старых файлов
    private let cleanupDaysThreshold = 30
    
    private init() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        documentsPath = paths[0].appendingPathComponent("ProfilePhotos")
        
        // Создаем директорию если её нет
        try? FileManager.default.createDirectory(at: documentsPath, withIntermediateDirectories: true)
        
        // Настраиваем кэш
        imageCache = NSCache<NSString, UIImage>()
        imageCache.countLimit = maxCacheCount
        imageCache.totalCostLimit = maxCacheSize
        imageCache.name = "ProfilePhotosCache"
        
        // Запускаем автоматическую очистку старых файлов при инициализации
        cleanupOldFiles()
    }
    
    func saveImage(_ image: UIImage, for profileId: UUID) -> String? {
        // Сжимаем изображение до максимального размера 500x500
        let resizedImage = resizeImage(image, maxSize: maxImageSize)
        
        // Используем качество сжатия из констант для баланса между размером и качеством
        guard let imageData = resizedImage.jpegData(compressionQuality: AppConstants.Images.compressionQuality) else {
            AppLogger.log("Error: Failed to convert image to JPEG data", level: .error, category: "ImageManager")
            ErrorManager.shared.showError(.imageSaveFailed)
            return nil
        }
        
        let fileName = "\(profileId.uuidString).jpg"
        let filePath = documentsPath.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: filePath)
            
            // Сохраняем в кэш после успешного сохранения (используем сжатое изображение)
            let cacheKey = fileName as NSString
            let cost = imageData.count
            imageCache.setObject(resizedImage, forKey: cacheKey, cost: cost)
            
            return fileName
        } catch {
            let errorMessage = error.localizedDescription
            AppLogger.log("Error saving image: \(errorMessage)", level: .error, category: "ImageManager")
            ErrorManager.shared.showError(.imageSaveFailed)
            return nil
        }
    }
    
    func loadImage(from path: String) -> UIImage? {
        let cacheKey = path as NSString
        
        // Пытаемся загрузить из кэша
        if let cachedImage = imageCache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        // Загружаем с диска
        let filePath = documentsPath.appendingPathComponent(path)
        guard let imageData = try? Data(contentsOf: filePath) else {
            // Не показываем ошибку при загрузке, так как это может быть нормальной ситуацией
            // (файл может быть удален или еще не создан)
            return nil
        }
        guard let image = UIImage(data: imageData) else {
            AppLogger.log("Error: Failed to create UIImage from data for path: \(path)", level: .error, category: "ImageManager")
            // Не показываем ошибку пользователю, так как это может быть поврежденный файл
            return nil
        }
        
        // Сохраняем в кэш
        let cost = imageData.count
        imageCache.setObject(image, forKey: cacheKey, cost: cost)
        
        return image
    }
    
    /// Асинхронная загрузка изображения с кэшированием
    func loadImageAsync(from path: String, completion: @escaping (UIImage?) -> Void) {
        let cacheKey = path as NSString
        
        // Пытаемся загрузить из кэша синхронно
        if let cachedImage = imageCache.object(forKey: cacheKey) {
            DispatchQueue.main.async {
                completion(cachedImage)
            }
            return
        }
        
        // Загружаем с диска асинхронно
        cacheQueue.async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let filePath = self.documentsPath.appendingPathComponent(path)
            guard let imageData = try? Data(contentsOf: filePath) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let image = UIImage(data: imageData) else {
                AppLogger.log("Error: Failed to create UIImage from data for path: \(path)", level: .error, category: "ImageManager")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Сохраняем в кэш
            let cost = imageData.count
            self.imageCache.setObject(image, forKey: cacheKey, cost: cost)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    func deleteImage(at path: String) {
        // Удаляем из кэша
        let cacheKey = path as NSString
        imageCache.removeObject(forKey: cacheKey)
        
        // Удаляем файл
        let filePath = documentsPath.appendingPathComponent(path)
        do {
            try FileManager.default.removeItem(at: filePath)
        } catch {
            // Не критично, если не удалось удалить файл
            AppLogger.log("Warning: Failed to delete image at path \(path): \(error.localizedDescription)", level: .warning, category: "ImageManager")
        }
    }
    
    /// Очищает кэш изображений
    func clearCache() {
        imageCache.removeAllObjects()
        AppLogger.log("Image cache cleared", level: .info, category: "ImageManager")
    }
    
    // MARK: - Image Resizing
    
    /// Сжимает изображение до указанного максимального размера, сохраняя пропорции
    private func resizeImage(_ image: UIImage, maxSize: CGFloat) -> UIImage {
        let size = image.size
        
        // Если изображение уже меньше максимального размера, возвращаем его как есть
        if size.width <= maxSize && size.height <= maxSize {
            return image
        }
        
        // Вычисляем новый размер с сохранением пропорций
        let aspectRatio = size.width / size.height
        var newSize: CGSize
        
        if size.width > size.height {
            newSize = CGSize(width: maxSize, height: maxSize / aspectRatio)
        } else {
            newSize = CGSize(width: maxSize * aspectRatio, height: maxSize)
        }
        
        // Создаем новый контекст для рендеринга
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        // Рисуем изображение в новом размере
        image.draw(in: CGRect(origin: .zero, size: newSize))
        
        // Получаем сжатое изображение
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            // Если не удалось сжать, возвращаем оригинал
            return image
        }
        
        return resizedImage
    }
    
    // MARK: - File Cleanup
    
    /// Автоматически очищает файлы старше указанного количества дней
    private func cleanupOldFiles() {
        cacheQueue.async { [weak self] in
            guard let self = self else { return }
            
            let fileManager = FileManager.default
            let cutoffDate = Date().addingTimeInterval(-Double(self.cleanupDaysThreshold * 24 * 60 * 60))
            
            guard let files = try? fileManager.contentsOfDirectory(at: self.documentsPath, includingPropertiesForKeys: [.creationDateKey, .contentModificationDateKey]) else {
                return
            }
            
            var deletedCount = 0
            var totalSizeFreed: Int64 = 0
            
            for file in files {
                // Получаем дату модификации файла
                guard let attributes = try? fileManager.attributesOfItem(atPath: file.path),
                      let modificationDate = attributes[.modificationDate] as? Date else {
                    continue
                }
                
                // Если файл старше порога, удаляем его
                if modificationDate < cutoffDate {
                    // Получаем размер файла перед удалением
                    if let fileSize = attributes[.size] as? Int64 {
                        totalSizeFreed += fileSize
                    }
                    
                    do {
                        try fileManager.removeItem(at: file)
                        deletedCount += 1
                        
                        // Также удаляем из кэша
                        let fileName = file.lastPathComponent
                        self.imageCache.removeObject(forKey: fileName as NSString)
                    } catch {
                        AppLogger.log("Warning: Failed to delete old file \(file.lastPathComponent): \(error.localizedDescription)", level: .warning, category: "ImageManager")
                    }
                }
            }
            
            if deletedCount > 0 {
                let sizeInMB = Double(totalSizeFreed) / (1024 * 1024)
                AppLogger.log("Cleaned up \(deletedCount) old image file(s), freed \(String(format: "%.2f", sizeInMB)) MB", level: .info, category: "ImageManager")
            }
        }
    }
    
    /// Ручная очистка старых файлов (можно вызвать из Settings)
    func cleanupOldFilesManually() {
        cleanupOldFiles()
    }
}

