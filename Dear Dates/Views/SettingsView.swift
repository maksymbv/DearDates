//
//  SettingsView.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI
import SwiftData
import MessageUI
import UIKit
import UniformTypeIdentifiers

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.clear
                    .appBackground(colorScheme: colorScheme)
                    .ignoresSafeArea()
                
                List {
                    SettingsUserProfileSection {
                        viewModel.showingUserProfile = true
                    }
                    
                    SettingsMainSection()
                    
                    SettingsDataSection(
                        onExport: { viewModel.exportData(context: modelContext) },
                        onImport: { viewModel.importData() }
                    )
                    
                    SettingsSupportSection(
                        onReportBug: { viewModel.openSupportEmail() },
                        onRequestFeature: { viewModel.openFeatureRequest() }
                    )
                    
                    SettingsAboutSection(
                        appVersion: viewModel.getAppVersion(),
                        onVersionLongPress: {
                            viewModel.showingEasterEgg = true
                        }
                    )
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("navigation.settings".localized)
            .fullScreenCover(isPresented: $viewModel.showingUserProfile) {
                UserProfileView()
            }
            .fullScreenCover(isPresented: $viewModel.showingEasterEgg) {
                EasterEggView()
            }
            .sheet(isPresented: $viewModel.showingSupportEmail) {
                MailView(
                    subject: "settings.support_email_subject".localized,
                    messageBody: viewModel.getEmailTemplate(),
                    toRecipients: ["max.qb@icloud.com"]
                )
            }
            .sheet(isPresented: $viewModel.showingFeatureRequest) {
                MailView(
                    subject: "settings.request_feature_subject".localized,
                    messageBody: viewModel.getEmailTemplate(),
                    toRecipients: ["max.qb@icloud.com"]
                )
            }
            .sheet(isPresented: $viewModel.showingExportSheet) {
                if let url = viewModel.exportFileURL {
                    ActivityViewController(activityItems: [url])
                }
            }
            .fileImporter(
                isPresented: $viewModel.showingImportPicker,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                viewModel.handleImportResult(result, context: modelContext)
            }
        }
    }
}

struct ThemeSettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.clear
                .appBackground(colorScheme: colorScheme)
                .ignoresSafeArea()
            
            Form {
                Section(header: Text("label.theme".localized)) {
                    Button(action: { settingsManager.themeType = .system }) {
                        HStack {
                            Text("label.theme_system".localized)
                            Spacer()
                            if settingsManager.themeType == .system {
                                Image(systemName: "checkmark")
                                    .foregroundColor(settingsManager.accentColor.color)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                    
                    Button(action: { settingsManager.themeType = .light }) {
                        HStack {
                            Text("label.theme_light".localized)
                            Spacer()
                            if settingsManager.themeType == .light {
                                Image(systemName: "checkmark")
                                    .foregroundColor(settingsManager.accentColor.color)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                    
                    Button(action: { settingsManager.themeType = .dark }) {
                        HStack {
                            Text("label.theme_dark".localized)
                            Spacer()
                            if settingsManager.themeType == .dark {
                                Image(systemName: "checkmark")
                                    .foregroundColor(settingsManager.accentColor.color)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                Section(header: Text("label.accent_color".localized)) {
                    Button(action: { settingsManager.accentColor = .pink }) {
                        HStack {
                            Circle()
                                .fill(Color.pink)
                                .frame(width: 20, height: 20)
                            Text("label.color_pink".localized)
                            Spacer()
                            if settingsManager.accentColor == .pink {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.pink)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                    
                    Button(action: { settingsManager.accentColor = .blue }) {
                            HStack {
                                Circle()
                                .fill(Color.blue)
                                    .frame(width: 20, height: 20)
                            Text("label.color_blue".localized)
                            Spacer()
                            if settingsManager.accentColor == .blue {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                        }
                    }
                    }
                    .foregroundColor(.primary)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("section.appearance".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NotificationsSettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.clear
                .appBackground(colorScheme: colorScheme)
                .ignoresSafeArea()
            
            Form {
                Section(header: Text("navigation.notifications".localized)) {
                    Toggle("label.enable_notifications".localized, isOn: $settingsManager.notificationsEnabled)
                    
                    if settingsManager.notificationsEnabled {
                        Text("message.notifications_enabled_description".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("message.notifications_disabled".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("navigation.notifications".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Mail View
struct MailView: UIViewControllerRepresentable {
    let subject: String
    let messageBody: String
    let toRecipients: [String]
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = context.coordinator
        mail.setToRecipients(toRecipients)
        mail.setSubject(subject)
        mail.setMessageBody(messageBody, isHTML: false)
        return mail
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let dismiss: DismissAction
        
        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            dismiss()
        }
    }
}

// MARK: - Activity View Controller for Export
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}


