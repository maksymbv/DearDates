//
//  AddEditProfileView.swift
//  DearDates
//
//  Created on 2025
//

import SwiftUI

struct AddEditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var imageManager: ImageManager
    
    var profile: Profile?
    
    @State private var name: String = ""
    @State private var dateOfBirth: Date? = nil
    @State private var dateWasSelected: Bool = false
    @State private var notes: String = ""
    @State private var notificationsEnabled: Bool = true
    @State private var selectedReminderDays: Set<Int> = [7, 1]
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var photoPath: String?
    @State private var showingDeleteAlert = false
    @State private var showingDatePicker = false
    private let availableReminderDays = [1, 3, 7, 14, 30]
    
    private var dateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 1900, month: 1, day: 1)) ?? Date()
        let endDate = Date()
        return startDate...endDate
    }
    
    init(profile: Profile? = nil) {
        self.profile = profile
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.clear
                    .appBackground(colorScheme: colorScheme)
                    .ignoresSafeArea()
                
                Form {
                    Section(header: Text("label.photo".localized)) {
                        HStack {
                            Spacer()
                            
                            Button(action: { showingImagePicker = true }) {
                                if let image = selectedImage {
                                    AvatarView(image: image, name: name.isEmpty ? "A" : name, avatarColorHue: profile?.avatarColorHue ?? 0.5, size: 100)
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
                                    .background(settingsManager.accentColor.color.opacity(0.1))
                                    .clipShape(Circle())
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical)
                    }
                    
                    Section(header: Text("section.main_info".localized)) {
                        TextField("label.name".localized, text: $name)
                        
                        Button(action: { showingDatePicker = true }) {
                            HStack {
                                Text("label.birth_date".localized)
                                    .foregroundColor(settingsManager.accentColor.color)
                                Spacer()
                                if let date = dateOfBirth {
                                    Text(formatDate(date))
                                        .foregroundColor(.primary)
                                } else {
                                    Text("label.not_selected".localized)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("label.notes".localized)) {
                        LimitedTextEditor(
                            text: $notes,
                            maxLength: AppConstants.TextLimits.maxNotesLength,
                            height: AppConstants.UI.notesFieldHeight
                        )
                    }
                    
                    Section(header: Text("navigation.notifications".localized)) {
                        Toggle("label.enable_notifications".localized, isOn: $notificationsEnabled)
                        
                        if notificationsEnabled {
                            ForEach(availableReminderDays, id: \.self) { days in
                                Toggle("\(localizationManager.localizedString("label.reminder_days_before")) \(days) \(localizationManager.daysText(days))", isOn: Binding(
                                    get: { selectedReminderDays.contains(days) },
                                    set: { isOn in
                                        if isOn {
                                            selectedReminderDays.insert(days)
                                        } else {
                                            selectedReminderDays.remove(days)
                                        }
                                    }
                                ))
                            }
                        }
                    }
                    
                    if profile != nil {
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
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(profile == nil ? "navigation.new_profile".localized : "navigation.edit_profile".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { saveProfile() }) {
                        Image(systemName: "checkmark")
                    }
                    .disabled(name.isEmpty || (profile == nil && !dateWasSelected))
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .sheet(isPresented: $showingDatePicker) {
                NavigationView {
                    DatePicker("navigation.birth_date".localized, 
                              selection: Binding(
                                get: { dateOfBirth ?? Date() },
                                set: { newDate in
                                    dateOfBirth = newDate
                                    dateWasSelected = true
                                }
                              ),
                              in: dateRange, 
                              displayedComponents: .date)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .environment(\.locale, localizationManager.currentLanguage.locale)
                        .navigationTitle("navigation.birth_date".localized)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: { showingDatePicker = false }) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                }
                .presentationDetents([.medium])
            }
            .alert("message.delete_profile_confirm".localized, isPresented: $showingDeleteAlert) {
                Button("button.cancel".localized, role: .cancel) { }
                Button("button.delete".localized, role: .destructive) {
                    deleteProfile()
                }
            } message: {
                Text("message.delete_profile_description".localized)
            }
            .onAppear {
                if let profile = profile {
                    name = profile.name
                    dateOfBirth = profile.dateOfBirth
                    dateWasSelected = true // Дата уже установлена для существующего профиля
                    notes = profile.notes
                    notificationsEnabled = profile.notificationsEnabled
                    selectedReminderDays = Set(profile.reminderDays)
                    photoPath = profile.photoPath
                    
                    if let photoPath = profile.photoPath {
                        selectedImage = imageManager.loadImage(from: photoPath)
                    }
                }
            }
        }
    }
    
    private func saveProfile() {
        var savedPhotoPath = photoPath
        
        // Сохраняем новое фото если оно было выбрано
        if let image = selectedImage {
            let profileId = profile?.id ?? UUID()
            if let path = imageManager.saveImage(image, for: profileId) {
                savedPhotoPath = path
                
                // Удаляем старое фото если оно было
                if let oldPath = photoPath, oldPath != path {
                    imageManager.deleteImage(at: oldPath)
                }
            }
        }
        
        let reminderDaysArray = Array(selectedReminderDays).sorted()
        
        guard let selectedDate = dateOfBirth else {
            // Не должно произойти из-за disabled кнопки, но на всякий случай
            return
        }
        
        if let existingProfile = profile {
            // Обновляем существующий профиль
            var updatedProfile = existingProfile
            updatedProfile.name = name
            updatedProfile.dateOfBirth = selectedDate
            updatedProfile.notes = notes
            updatedProfile.notificationsEnabled = notificationsEnabled
            updatedProfile.reminderDays = reminderDaysArray
            updatedProfile.photoPath = savedPhotoPath
            
            dataManager.updateProfile(updatedProfile, notificationManager: notificationManager)
            notificationManager.updateNotifications(for: updatedProfile)
        } else {
            // Создаем новый профиль
            let newProfile = Profile(
                name: name,
                dateOfBirth: selectedDate,
                photoPath: savedPhotoPath,
                notes: notes,
                notificationsEnabled: notificationsEnabled,
                reminderDays: reminderDaysArray
            )
            
            dataManager.addProfile(newProfile)
            notificationManager.scheduleNotifications(for: newProfile)
        }
        
        dismiss()
    }
    
    private func deleteProfile() {
        guard let profile = profile else { return }
        
        // Удаляем фото если оно есть
        if let photoPath = profile.photoPath {
            imageManager.deleteImage(at: photoPath)
        }
        
        // Удаляем профиль (это также удалит все подарки и уведомления)
        dataManager.deleteProfile(profile, notificationManager: notificationManager)
        
        dismiss()
    }
    
    private func formatDate(_ date: Date) -> String {
        DateFormatterHelper.formatLongDate(date, locale: localizationManager.currentLanguage.locale)
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


