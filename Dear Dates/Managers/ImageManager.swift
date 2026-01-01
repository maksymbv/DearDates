//
//  ImageManager.swift
//  DearDates
//
//  Created on 2025
//

import Foundation
import SwiftUI
import UIKit
import Combine

class ImageManager: ObservableObject {
    static let shared = ImageManager()
    
    private let documentsPath: URL
    
    private init() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        documentsPath = paths[0].appendingPathComponent("ProfilePhotos")
        
        // Создаем директорию если её нет
        try? FileManager.default.createDirectory(at: documentsPath, withIntermediateDirectories: true)
    }
    
    func saveImage(_ image: UIImage, for profileId: UUID) -> String? {
        guard let imageData = image.jpegData(compressionQuality: AppConstants.Images.compressionQuality) else {
            return nil
        }
        
        let fileName = "\(profileId.uuidString).jpg"
        let filePath = documentsPath.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: filePath)
            return fileName
        } catch {
            AppLogger.log("Error saving image: \(error.localizedDescription)", level: .error, category: "ImageManager")
            return nil
        }
    }
    
    func loadImage(from path: String) -> UIImage? {
        let filePath = documentsPath.appendingPathComponent(path)
        guard let imageData = try? Data(contentsOf: filePath) else {
            return nil
        }
        return UIImage(data: imageData)
    }
    
    func deleteImage(at path: String) {
        let filePath = documentsPath.appendingPathComponent(path)
        try? FileManager.default.removeItem(at: filePath)
    }
}

