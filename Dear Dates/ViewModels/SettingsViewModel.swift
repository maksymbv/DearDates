//
//  SettingsViewModel.swift
//  DearDates
//
//  Created on 2026
//

import Foundation
import SwiftData
import MessageUI
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var showingSupportEmail = false
    @Published var showingFeatureRequest = false
    @Published var showingUserProfile = false
    @Published var showingExportSheet = false
    @Published var showingImportPicker = false
    @Published var showingEasterEgg = false
    @Published var exportFileURL: URL?
    
    private let dataManager: DataManager
    private let errorManager: ErrorManager
    
    init(dataManager: DataManager? = nil, errorManager: ErrorManager? = nil) {
        self.dataManager = dataManager ?? DataManager.shared
        self.errorManager = errorManager ?? ErrorManager.shared
    }
    
    // MARK: - Export/Import
    
    func exportData(context: ModelContext) {
        guard let url = dataManager.exportToFile(context: context) else {
            return
        }
        exportFileURL = url
        showingExportSheet = true
    }
    
    func importData() {
        showingImportPicker = true
    }
    
    func handleImportResult(_ result: Result<[URL], Error>, context: ModelContext) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            guard DataExportImportManager.shared.importFromFile(at: url) != nil else {
                return
            }
            
            guard let data = try? Data(contentsOf: url) else {
                return
            }
            
            _ = dataManager.importData(from: data)
        case .failure(let error):
            AppLogger.log("Error importing file: \(error.localizedDescription)", level: .error, category: "SettingsViewModel")
            errorManager.showError(.dataLoadFailed(error.localizedDescription))
        }
    }
    
    // MARK: - Email
    
    func openSupportEmail() {
        if MFMailComposeViewController.canSendMail() {
            showingSupportEmail = true
        } else {
            openMailtoLink(subject: "settings.support_email_subject".localized)
        }
    }
    
    func openFeatureRequest() {
        if MFMailComposeViewController.canSendMail() {
            showingFeatureRequest = true
        } else {
            openMailtoLink(subject: "settings.request_feature_subject".localized)
        }
    }
    
    private func openMailtoLink(subject: String) {
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "mailto:max.qb@icloud.com?subject=\(encodedSubject)") {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - App Info
    
    func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "1.2"
    }
    
    func getEmailTemplate() -> String {
        let appVersion = getAppVersion()
        let iosVersion = UIDevice.current.systemVersion
        
        return """
        Application Name: Dear Dates
        iOS: \(iosVersion)
        App Version: \(appVersion)
        --------------------------------------
        
        """
    }
}

