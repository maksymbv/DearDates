//
//  SettingsView.swift
//  DearDates
//
//  Created on 2025
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .light ? Color.appBackground : Color(.systemBackground))
                    .ignoresSafeArea()
                
                List {
                    NavigationLink(destination: ThemeSettingsView()) {
                        HStack {
                            Image(systemName: "paintbrush.fill")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            Text("Тема")
                        }
                    }
                    
                    NavigationLink(destination: NotificationsSettingsView()) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.orange)
                                .frame(width: 30)
                            Text("Уведомления")
                        }
                    }
                    
                    Section(header: Text("О приложении")) {
                        HStack {
                            Text("Версия")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.secondary)
                        }
                        
                        Text("Dear Dates - приложение для отслеживания дней рождения и управления подарками")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Настройки")
        }
    }
}

struct ThemeSettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            (colorScheme == .light ? Color.appBackground : Color(.systemBackground))
                .ignoresSafeArea()
            
            Form {
                Section(header: Text("Внешний вид")) {
                    Toggle("Темная тема", isOn: $settingsManager.isDarkMode)
                    
                    Picker("Акцентный цвет", selection: $settingsManager.accentColor) {
                        ForEach(AccentColor.allCases, id: \.self) { color in
                            HStack {
                                Circle()
                                    .fill(color.color)
                                    .frame(width: 20, height: 20)
                                Text(color == .pink ? "Розовый" : "Синий")
                            }
                            .tag(color)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Тема")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NotificationsSettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            (colorScheme == .light ? Color.appBackground : Color(.systemBackground))
                .ignoresSafeArea()
            
            Form {
                Section(header: Text("Уведомления")) {
                    Toggle("Включить уведомления", isOn: $settingsManager.notificationsEnabled)
                    
                    if settingsManager.notificationsEnabled {
                        Text("Уведомления будут приходить согласно настройкам каждого профиля")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Все уведомления отключены")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Уведомления")
        .navigationBarTitleDisplayMode(.inline)
    }
}


