//
//  AvatarView.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI

struct AvatarView: View {
    let image: UIImage?
    let name: String
    let avatarColorHue: Double
    let size: CGFloat
    let maxFontSize: CGFloat? // Опциональный максимальный размер шрифта буквы
    @Environment(\.colorScheme) var colorScheme
    
    init(image: UIImage?, name: String, avatarColorHue: Double, size: CGFloat = 60, maxFontSize: CGFloat? = nil) {
        self.image = image
        self.name = name
        self.avatarColorHue = avatarColorHue
        self.size = size
        self.maxFontSize = maxFontSize
    }
    
    // Вычисляем размер шрифта буквы с ограничением для больших экранов
    private var avatarFontSize: Font {
        let baseFontSize: CGFloat = size > 60 ? size * 0.83 : 22 // .title2 примерно 22pt
        // Используем переданный maxFontSize или значение по умолчанию
        let defaultMaxFontSize: CGFloat = 40
        let finalMaxFontSize = maxFontSize ?? defaultMaxFontSize
        let finalSize = min(baseFontSize, finalMaxFontSize)
        return .system(size: finalSize)
    }
    
    // Безопасный hue: проверяем на NaN и бесконечность
    private var safeHue: Double {
        if avatarColorHue.isNaN || !avatarColorHue.isFinite {
            // Генерируем hue на основе имени, если значение невалидно
            let hash = name.hashValue
            return Double(abs(hash) % 360) / 360.0
        }
        return max(0.0, min(1.0, avatarColorHue)) // Ограничиваем диапазон 0-1
    }
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: max(size, 1), height: max(size, 1))
                    .clipped()
                    .clipShape(Circle())
                    .accessibilityLabel("accessibility.profile_photo".localized + " \(name)")
            } else {
                Circle()
                    .fill(Color.pastelColor(hue: safeHue).opacity(colorScheme == .dark ? 0.6 : 0.7))
                    .frame(width: max(size, 1), height: max(size, 1))
                    .overlay(
                        Text(name.prefix(1).uppercased())
                            .font(avatarFontSize)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    )
                    .accessibilityLabel("accessibility.profile_avatar".localized + " \(name)")
            }
        }
    }
}
