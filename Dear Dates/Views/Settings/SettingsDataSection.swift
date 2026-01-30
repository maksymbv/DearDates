//
//  SettingsDataSection.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI
import SwiftData

struct SettingsDataSection: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.modelContext) var modelContext
    @ObservedObject var viewModel: SettingsViewModel
    @State private var showingiCloudAlert = false
    @State private var showingFirstConfirm = false
    @State private var showingSecondConfirm = false
    
    var body: some View {
        Section(header: Text("settings.data".localized)) {
            Toggle(isOn: $settingsManager.iCloudSyncEnabled) {
                HStack {
                    Image(systemName: "icloud.fill")
                        .foregroundColor(.blue)
                        .frame(width: 30)
                        .accessibilityHidden(true)
                    Text("settings.icloud_sync".localized)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                }
            }
            .accessibilityLabel("accessibility.icloud_sync".localized)
            .onChange(of: settingsManager.iCloudSyncEnabled) { oldValue, newValue in
                if newValue {
                    showingiCloudAlert = true
                }
            }
            
            Button(action: { viewModel.exportData(context: modelContext) }) {
                HStack {
                    Image(systemName: "square.and.arrow.up.fill")
                        .foregroundColor(.blue)
                        .frame(width: 30)
                        .accessibilityHidden(true)
                    Text("settings.export_data".localized)
                        .foregroundColor(.primary)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                }
            }
            .accessibilityLabel("accessibility.export_data".localized)
            
            HStack {
                Image(systemName: "trash.fill")
                    .foregroundColor(.red)
                    .frame(width: 30)
                    .accessibilityHidden(true)
                Text("settings.delete_all_data".localized)
                    .foregroundColor(.red)
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                showingFirstConfirm = true
            }
            .accessibilityLabel("accessibility.delete_all_data".localized)
            .accessibilityAddTraits(.isButton)
            
            #if DEBUG
            // Генерация тестовых профилей для разных языков (только в DEBUG)
            Button(action: {
                DataManager.shared.generateTestProfilesRussian(context: modelContext)
            }) {
                HStack {
                    Image(systemName: "person.2.badge.gearshape.fill")
                        .foregroundColor(.blue)
                        .frame(width: 30)
                        .accessibilityHidden(true)
                    Text("Generate RU test profiles")
                        .foregroundColor(.primary)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                }
            }
            .accessibilityLabel("Generate Russian test profiles")
            
            Button(action: {
                DataManager.shared.generateTestProfilesEnglish(context: modelContext)
            }) {
                HStack {
                    Image(systemName: "person.2.badge.gearshape.fill")
                        .foregroundColor(.blue)
                        .frame(width: 30)
                        .accessibilityHidden(true)
                    Text("Generate EN test profiles")
                        .foregroundColor(.primary)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                }
            }
            .accessibilityLabel("Generate English test profiles")
            
            Button(action: {
                DataManager.shared.generateTestProfilesUkrainian(context: modelContext)
            }) {
                HStack {
                    Image(systemName: "person.2.badge.gearshape.fill")
                        .foregroundColor(.blue)
                        .frame(width: 30)
                        .accessibilityHidden(true)
                    Text("Generate UA test profiles")
                        .foregroundColor(.primary)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                }
            }
            .accessibilityLabel("Generate Ukrainian test profiles")
            #endif
        }
        .alert("settings.icloud_sync_restart_title".localized, isPresented: $showingiCloudAlert) {
            Button("button.ok".localized, role: .cancel) { }
        } message: {
            Text("settings.icloud_sync_restart_message".localized)
        }
        .alert("settings.delete_all_data_confirm_title".localized, isPresented: $showingFirstConfirm) {
            Button("button.cancel".localized, role: .cancel) { }
            Button("settings.delete_all_data_confirm_button".localized, role: .destructive) {
                showingSecondConfirm = true
            }
        } message: {
            Text("settings.delete_all_data_confirm_message".localized)
        }
        .alert("settings.delete_all_data_final_title".localized, isPresented: $showingSecondConfirm) {
            Button("button.cancel".localized, role: .cancel) { }
            Button("settings.delete_all_data_final_button".localized, role: .destructive) {
                deleteAllData()
            }
        } message: {
            Text("settings.delete_all_data_final_message".localized)
        }
    }
    
    private func deleteAllData() {
        let success = DataManager.shared.deleteAllData(context: modelContext, notificationManager: NotificationManager.shared)
        if success {
            viewModel.statsRefreshId = UUID()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NotificationCenter.default.post(name: NSNotification.Name("NavigateToMainTab"), object: nil)
            }
        }
    }
}

