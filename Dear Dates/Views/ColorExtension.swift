//
//  ColorExtension.swift
//  DearDates
//
//  Created on 2025
//

import SwiftUI

extension Color {
    /// Генерирует пастельный цвет на основе UUID для стабильного цвета профиля
    static func pastelColor(for uuid: UUID) -> Color {
        // Используем хеш UUID для генерации стабильного цвета
        let hash = uuid.uuidString.hashValue
        let hue = Double(abs(hash) % 360) / 360.0 // Оттенок от 0 до 1
        let saturation = 0.3 + Double(abs(hash / 1000) % 30) / 100.0 // Насыщенность 0.3-0.6
        let brightness = 0.85 + Double(abs(hash / 10000) % 15) / 100.0 // Яркость 0.85-1.0
        
        return Color(hue: hue, saturation: saturation, brightness: brightness)
    }
    
    /// Генерирует пастельный цвет на основе сохраненного hue компонента
    static func pastelColor(hue: Double) -> Color {
        // Используем сохраненный hue для генерации стабильного пастельного цвета
        // Насыщенность и яркость вычисляются из hue для консистентности
        let hash = Int(hue * 360)
        let saturation = 0.3 + Double(abs(hash / 10) % 30) / 100.0 // Насыщенность 0.3-0.6
        let brightness = 0.85 + Double(abs(hash / 100) % 15) / 100.0 // Яркость 0.85-1.0
        
        return Color(hue: hue, saturation: saturation, brightness: brightness)
    }
    
    static let appBackground = Color(hex: "FAF7F8")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

