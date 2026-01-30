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
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            List {
                SettingsUserProfileSection(statsRefreshId: viewModel.statsRefreshId)
                
                SettingsMainSection(viewModel: viewModel)
                
                SettingsDataSection(viewModel: viewModel)
                
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
        .navigationBarTitleDisplayMode(.inline)
        .tint(settingsManager.accentColor.color)
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
        .onAppear {
            TabBarHelper.hideTabBar()
            viewModel.navigatingToChild = false
        }
        .onDisappear {
            if !viewModel.navigatingToChild {
                TabBarHelper.showTabBar()
            }
        }
        .onChange(of: viewModel.showingThemeSettings) { _, newValue in
            if newValue { viewModel.navigatingToChild = true }
        }
        .onChange(of: viewModel.showingLanguageSettings) { _, newValue in
            if newValue { viewModel.navigatingToChild = true }
        }
        .navigationDestination(isPresented: $viewModel.showingThemeSettings) {
            ThemeSettingsView(onDismiss: { viewModel.showingThemeSettings = false })
        }
        .navigationDestination(isPresented: $viewModel.showingLanguageSettings) {
            LanguageSettingsView(onDismiss: { viewModel.showingLanguageSettings = false })
        }
    }
}

struct ThemeSettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.colorScheme) var colorScheme
    var onDismiss: () -> Void = {}
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
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
                    
                    Button(action: { settingsManager.accentColor = .green }) {
                        HStack {
                            Circle()
                                .fill(Color(red: 0.4, green: 0.7, blue: 0.5))
                                .frame(width: 20, height: 20)
                            Text("label.color_green".localized)
                            Spacer()
                            if settingsManager.accentColor == .green {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color(red: 0.4, green: 0.7, blue: 0.5))
                            }
                        }
                    }
                    .foregroundColor(.primary)
                    
                    Button(action: { settingsManager.accentColor = .yellow }) {
                        HStack {
                            Circle()
                                .fill(Color(red: 1.0, green: 0.85, blue: 0.4))
                                .frame(width: 20, height: 20)
                            Text("label.color_yellow".localized)
                            Spacer()
                            if settingsManager.accentColor == .yellow {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.4))
                            }
                        }
                    }
                    .foregroundColor(.primary)
                    
                    Button(action: { settingsManager.accentColor = .purple }) {
                        HStack {
                            Circle()
                                .fill(Color(red: 0.7, green: 0.5, blue: 0.9))
                                .frame(width: 20, height: 20)
                            Text("label.color_purple".localized)
                            Spacer()
                            if settingsManager.accentColor == .purple {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color(red: 0.7, green: 0.5, blue: 0.9))
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
        .onAppear { TabBarHelper.hideTabBar() }
        .onDisappear { onDismiss() }
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


