//
//  Constants.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI

struct AppConstants {
    struct TextLimits {
        static let maxProfileNameLength = 30
        static let maxEventNameLength = 50
        static let maxNotesLength = 500
        static let maxDescriptionLength = 10000
    }
    
    struct UI {
        static let notesFieldHeight: CGFloat = 150
        static let descriptionFieldHeight: CGFloat = 200
        static let animationDuration: Double = 0.3
        
        // Базовые размеры для стандартного iPhone (375pt ширина)
        static let baseScreenWidth: CGFloat = 375
        static let baseAvatarSize: CGFloat = 60
        static let baseCalendarHeight: CGFloat = 400
        static let baseSpacing: CGFloat = 12
    }
    
    struct Images {
        static let compressionQuality: CGFloat = 0.8
    }
}

// MARK: - Adaptive Sizing
extension View {
    /// Вычисляет адаптивный размер на основе ширины экрана
    /// - Parameters:
    ///   - baseSize: Базовый размер для стандартного iPhone (375pt)
    ///   - geometry: GeometryProxy для получения ширины экрана
    /// - Returns: Масштабированный размер
    func adaptiveSize(baseSize: CGFloat, geometry: GeometryProxy) -> CGFloat {
        let screenWidth = geometry.size.width
        let scaleFactor = screenWidth / AppConstants.UI.baseScreenWidth
        // Ограничиваем масштабирование: минимум 1.0, максимум 1.2 для очень больших экранов
        let clampedScale = min(max(scaleFactor, 1.0), 1.2)
        return baseSize * clampedScale
    }
}

// MARK: - Environment Key for Screen Size
struct ScreenSizeKey: EnvironmentKey {
    static let defaultValue: CGSize = UIScreen.main.bounds.size
}

extension EnvironmentValues {
    var screenSize: CGSize {
        get { self[ScreenSizeKey.self] }
        set { self[ScreenSizeKey.self] = newValue }
    }
}

// MARK: - Helper для адаптивных размеров
struct AdaptiveSize {
    /// Вычисляет адаптивный размер на основе ширины экрана
    static func size(baseSize: CGFloat, screenWidth: CGFloat) -> CGFloat {
        // Валидация: проверяем на валидные значения
        guard baseSize > 0, screenWidth > 0, AppConstants.UI.baseScreenWidth > 0 else {
            return baseSize // Возвращаем базовый размер при ошибке
        }
        
        let scaleFactor = screenWidth / AppConstants.UI.baseScreenWidth
        // Ограничиваем масштабирование: минимум 1.0, максимум 1.2 для очень больших экранов
        let clampedScale = min(max(scaleFactor, 1.0), 1.2)
        let result = baseSize * clampedScale
        
        // Проверяем результат на NaN и бесконечность
        guard result.isFinite && !result.isNaN else {
            return baseSize
        }
        
        return result
    }
    
    /// Вычисляет адаптивный размер на основе текущего экрана
    static func size(baseSize: CGFloat) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return size(baseSize: baseSize, screenWidth: screenWidth)
    }
    
    /// Вычисляет адаптивный размер шрифта для иконок
    /// Использует более мягкое масштабирование (до 1.1x) для декоративных элементов
    static func iconSize(baseSize: CGFloat) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        
        // Валидация: проверяем на валидные значения
        guard baseSize > 0, screenWidth > 0, AppConstants.UI.baseScreenWidth > 0 else {
            return baseSize
        }
        
        let scaleFactor = screenWidth / AppConstants.UI.baseScreenWidth
        // Для иконок используем более мягкое масштабирование: максимум 1.1x
        let clampedScale = min(max(scaleFactor, 1.0), 1.1)
        let result = baseSize * clampedScale
        
        // Проверяем результат на NaN и бесконечность
        guard result.isFinite && !result.isNaN else {
            return baseSize
        }
        
        return result
    }
}
