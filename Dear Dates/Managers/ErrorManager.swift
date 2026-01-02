//
//  ErrorManager.swift
//  DearDates
//
//  Created on 2026
//

import Foundation
import SwiftUI
import Combine

enum AppError: LocalizedError {
    case dataSaveFailed(String)
    case dataLoadFailed(String)
    case imageSaveFailed
    case imageLoadFailed
    case notificationPermissionDenied
    case photoLibraryPermissionDenied
    case validationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .dataSaveFailed(let details):
            return "Ошибка сохранения данных: \(details)"
        case .dataLoadFailed(let details):
            return "Ошибка загрузки данных: \(details)"
        case .imageSaveFailed:
            return "Не удалось сохранить изображение"
        case .imageLoadFailed:
            return "Не удалось загрузить изображение"
        case .notificationPermissionDenied:
            return "Доступ к уведомлениям запрещен"
        case .photoLibraryPermissionDenied:
            return "Доступ к фотографиям запрещен"
        case .validationFailed(let message):
            return "Ошибка валидации: \(message)"
        }
    }
}

class ErrorManager: ObservableObject {
    static let shared = ErrorManager()
    
    @Published var currentError: AppError?
    @Published var showError: Bool = false
    
    private init() {}
    
    func showError(_ error: AppError) {
        DispatchQueue.main.async {
            self.currentError = error
            self.showError = true
            AppLogger.log("Error shown to user: \(error.localizedDescription)", level: .error, category: "ErrorManager")
        }
    }
    
    func clearError() {
        currentError = nil
        showError = false
    }
}

// MARK: - Error View Modifier
struct ErrorAlertModifier: ViewModifier {
    @ObservedObject var errorManager: ErrorManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    func body(content: Content) -> some View {
        content
            .alert("error.title".localized, isPresented: $errorManager.showError) {
                Button("button.ok".localized, role: .cancel) {
                    errorManager.clearError()
                }
            } message: {
                if let error = errorManager.currentError {
                    Text(localizedErrorMessage(for: error))
                }
            }
    }
    
    private func localizedErrorMessage(for error: AppError) -> String {
        switch error {
        case .dataSaveFailed(let details):
            return String(format: "error.data_save_failed".localized, details)
        case .dataLoadFailed(let details):
            return String(format: "error.data_load_failed".localized, details)
        case .imageSaveFailed:
            return "error.image_save_failed".localized
        case .imageLoadFailed:
            return "error.image_load_failed".localized
        case .notificationPermissionDenied:
            return "error.notification_permission_denied".localized
        case .photoLibraryPermissionDenied:
            return "error.photo_library_permission_denied".localized
        case .validationFailed(let message):
            return String(format: "error.validation_failed".localized, message)
        }
    }
}

extension View {
    func errorAlert() -> some View {
        modifier(ErrorAlertModifier(errorManager: ErrorManager.shared))
    }
}

