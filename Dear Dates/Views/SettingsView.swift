//
//  SettingsView.swift
//  DearDates
//
//  Created on 2025
//

import SwiftUI
import MessageUI
import UIKit

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var imageManager: ImageManager
    @State private var showingSupportEmail = false
    @State private var showingFeatureRequest = false
    @State private var showingUserProfile = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.clear
                    .appBackground(colorScheme: colorScheme)
                    .ignoresSafeArea()
                
                List {
                    // Профиль пользователя вверху
                    Section {
                        Button(action: { showingUserProfile = true }) {
                            HStack(spacing: 16) {
                                // Аватарка
                                let userProfile = dataManager.getUserProfile()
                                let userImage = userProfile.photoPath.flatMap { imageManager.loadImage(from: $0) }
                                
                                if let image = userImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(settingsManager.accentColor.color.opacity(0.2))
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 30))
                                                .foregroundColor(settingsManager.accentColor.color)
                                        )
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    // Имя пользователя
                                    Text(userProfile.name.isEmpty ? "navigation.user_profile".localized : userProfile.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    // Статистика
                                    HStack(spacing: 20) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "person.2.fill")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Text("\(dataManager.getTotalProfilesCount())")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        HStack(spacing: 4) {
                                            Image(systemName: "gift.fill")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Text("\(dataManager.getTotalGiftIdeasCount())")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Section(header: Text("settings.main".localized)) {
                    NavigationLink(destination: ThemeSettingsView()) {
                        HStack {
                            Image(systemName: "paintbrush.fill")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                                Text("section.appearance".localized)
                        }
                    }
                    
                    NavigationLink(destination: NotificationsSettingsView()) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.orange)
                                .frame(width: 30)
                                Text("navigation.notifications".localized)
                            }
                        }
                    }
                    
                    Section(header: Text("settings.other".localized)) {
                        Button(action: {
                            if MFMailComposeViewController.canSendMail() {
                                showingSupportEmail = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .frame(width: 30)
                                Text("settings.report_bug".localized)
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        Button(action: {
                            if MFMailComposeViewController.canSendMail() {
                                showingFeatureRequest = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                    .frame(width: 30)
                                Text("settings.request_feature".localized)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    
                    Section(header: Text("settings.about".localized)) {
                        HStack {
                            Text("label.version".localized)
                            Spacer()
                            Text(getAppVersion())
                                .foregroundColor(.secondary)
                        }
                        
                        Text("message.app_description".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("navigation.settings".localized)
            .sheet(isPresented: $showingUserProfile) {
                UserProfileView()
            }
            .onReceive(dataManager.$userProfile) { _ in
                // Обновляем view при изменении профиля пользователя
            }
            .sheet(isPresented: $showingSupportEmail) {
                MailView(
                    subject: "settings.support_email_subject".localized,
                    messageBody: getEmailTemplate(),
                    toRecipients: ["max.qb@icloud.com"]
                )
        }
            .sheet(isPresented: $showingFeatureRequest) {
                MailView(
                    subject: "settings.request_feature_subject".localized,
                    messageBody: getEmailTemplate(),
                    toRecipients: ["max.qb@icloud.com"]
                )
            }
        }
    }
    
    private func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "1.0.0"
    }
    
    private func getEmailTemplate() -> String {
        let appVersion = getAppVersion()
        let iosVersion = UIDevice.current.systemVersion
        let deviceModel = UIDevice.current.model
        
        return """
        Application Name: Dear Dates
        iOS: \(iosVersion)
        Device Model: \(deviceModel)
        App Version: \(appVersion)
        --------------------------------------
        
        """
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


