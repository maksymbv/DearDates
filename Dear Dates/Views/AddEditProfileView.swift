//
//  AddEditProfileView.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI
import SwiftData
import Photos

struct AddEditProfileView: View {
    @Query private var allProfiles: [Profile]
    
    @StateObject private var viewModel: AddEditProfileViewModel
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var showingImagePicker = false
    @State private var showingDeleteAlert = false
    @State private var profilesForValidation: [Profile] = []
    
    private var profile: Profile?
    var onSave: ((UUID) -> Void)? = nil
    
    init(profile: Profile? = nil, onSave: ((UUID) -> Void)? = nil) {
        self.profile = profile
        self.onSave = onSave
        let viewModel = AddEditProfileViewModel(
            profile: profile,
            allProfiles: []
        )
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // Computed property для безопасного доступа к allProfiles
    private var currentProfiles: [Profile] {
        !allProfiles.isEmpty ? allProfiles : profilesForValidation
    }
    
    // Цвет для toolbar кнопок: системный в iOS 18+, акцентный в старых версиях
    private var toolbarButtonColor: Color {
        if #available(iOS 18.0, *) {
            return .primary
        } else {
            return settingsManager.accentColor.color
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                Form {
                    photoSection
                    mainInfoSection
                    notesSection
                    notificationsSection
                    deleteSection
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(viewModel.profile == nil ? "navigation.new_profile".localized : "navigation.edit_profile".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    saveButton
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $viewModel.selectedImage)
            }
            .alert("message.delete_profile_confirm".localized, isPresented: $showingDeleteAlert) {
                Button("button.cancel".localized, role: .cancel) { }
                Button("button.delete".localized, role: .destructive) {
                    Task { @MainActor in
                        viewModel.deleteProfile(context: modelContext)
                        // Небольшая задержка для завершения операций удаления
                        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 секунды
                        dismiss()
                    }
                }
            } message: {
                Text("message.delete_profile_description".localized)
            }
            .onAppear {
                // Сохраняем профили в @State для использования в ViewModel
                updateProfilesForValidation()
            }
            .tint(settingsManager.accentColor.color)
        }
    }
    
    // MARK: - Photo Section
    
    @ViewBuilder
    private var photoSection: some View {
                    Section(header: Text("label.photo".localized)) {
                        HStack {
                            Spacer()
                photoButton
                Spacer()
            }
            .padding(.vertical)
        }
    }
    
    private var photoButton: some View {
        Button(action: {
            viewModel.checkPhotoLibraryPermission { granted in
                if granted {
                    showingImagePicker = true
                }
            }
        }) {
            photoContent
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("accessibility.add_photo_button".localized)
        .accessibilityHint("accessibility.add_photo_button_hint".localized)
    }
    
    @ViewBuilder
    private var photoContent: some View {
        if let image = viewModel.selectedImage {
            let displayName = viewModel.name.isEmpty ? "A" : viewModel.name
            let hue = viewModel.profile?.avatarColorHue ?? 0.5
            AvatarView(image: image, name: displayName, avatarColorHue: hue, size: 100)
                                } else {
                                    VStack {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(settingsManager.accentColor.color)
                                        Text("label.add_photo".localized)
                                            .font(.caption)
                                            .foregroundColor(settingsManager.accentColor.color)
                                    }
                                    .frame(width: 100, height: 100)
                                }
                            }
                            
    // MARK: - Main Info Section
                    
    @ViewBuilder
    private var mainInfoSection: some View {
        Section(header: Text("section.main_info".localized)) {
            TextField("label.profile_name_placeholder".localized, text: Binding(
                get: { viewModel.name },
                set: { newValue in
                    if newValue.count <= AppConstants.TextLimits.maxProfileNameLength {
                        viewModel.name = newValue
                    }
                }
            ))
            .accessibilityLabel("accessibility.name_field".localized)
            .accessibilityHint("accessibility.name_field_hint".localized)
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        }
    }
    // MARK: - Notes Section
    
    @ViewBuilder
    private var notesSection: some View {
                    Section(header: Text("label.notes".localized)) {
                        LimitedTextEditor(
                text: $viewModel.notes,
                            maxLength: AppConstants.TextLimits.maxNotesLength,
                            height: AppConstants.UI.notesFieldHeight,
                            placeholder: "label.profile_notes_placeholder".localized
                        )
                    }
    }
    
    // MARK: - Notifications Section
                    
    @ViewBuilder
    private var notificationsSection: some View {
                    Section(header: Text("navigation.notifications".localized)) {
            Toggle("label.enable_notifications".localized, isOn: $viewModel.notificationsEnabled)
                        
            if viewModel.notificationsEnabled {
                ForEach(viewModel.availableReminderDays, id: \.self) { days in
                    reminderToggle(for: days)
                }
            }
        }
    }
    
    private func reminderToggle(for days: Int) -> some View {
        let label = "\(localizationManager.localizedString("label.reminder_days_before")) \(days) \(localizationManager.daysText(days))"
        return Toggle(label, isOn: Binding(
            get: { viewModel.selectedReminderDays.contains(days) },
                                    set: { isOn in
                                        if isOn {
                    viewModel.selectedReminderDays.insert(days)
                                        } else {
                    viewModel.selectedReminderDays.remove(days)
                                        }
                                    }
                                ))
                            }
    
    // MARK: - Delete Section
                    
    @ViewBuilder
    private var deleteSection: some View {
        if viewModel.profile != nil {
                        Section {
                            Button(role: .destructive, action: { showingDeleteAlert = true }) {
                                HStack {
                                    Spacer()
                                    Text("button.delete_profile".localized)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
    
    // MARK: - Save Button
    
    private var saveButton: some View {
        Button(action: {
            if let profileId = viewModel.saveProfile(context: modelContext) {
                // Если это новый профиль (не редактирование), вызываем callback
                if viewModel.profile == nil, let onSave = onSave {
                    dismiss()
                    // Небольшая задержка для завершения сохранения
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        onSave(profileId)
                    }
                } else {
                    dismiss()
                }
            }
        }) {
            Image(systemName: "checkmark")
        }
        .disabled(viewModel.name.isEmpty)
    }
    
    // MARK: - Helper Methods
    
    private func updateProfilesForValidation() {
        // Обновляем @State с текущими профилями из @Query
        // Синхронизируем профили для валидации
        profilesForValidation = allProfiles
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}


