//
//  ViewModifiers.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI

extension View {
    /// Применяет стандартный фон приложения в зависимости от цветовой схемы
    func appBackground(colorScheme: ColorScheme) -> some View {
        self.background(
            Color(.systemBackground)
        )
    }
}
