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
    
    var profile: Profile?
    
    @State private var name: String = ""
    @State private var dateOfBirth: Date = Date()
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
                (colorScheme == .light ? Color.appBackground : Color(.systemBackground))
                    .ignoresSafeArea()
                
                Form {
                    Section(header: Text("Фото")) {
                        HStack {
                            Spacer()
                            
                            Button(action: { showingImagePicker = true }) {
                                if let image = selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                } else {
                                    VStack {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 40))
                                        Text("Добавить фото")
                                            .font(.caption)
                                    }
                                    .frame(width: 100, height: 100)
                                    .background(Color.gray.opacity(0.2))
                                    .clipShape(Circle())
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical)
                    }
                    
                    Section(header: Text("Основная информация")) {
                        TextField("Имя", text: $name)
                        
                        Button(action: { showingDatePicker = true }) {
                            HStack {
                                Text("Дата рождения")
                                Spacer()
                                Text(formatDate(dateOfBirth))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Section(header: Text("Заметки")) {
                        TextEditor(text: $notes)
                            .frame(height: 100)
                    }
                    
                    Section(header: Text("Уведомления")) {
                        Toggle("Включить уведомления", isOn: $notificationsEnabled)
                        
                        if notificationsEnabled {
                            ForEach(availableReminderDays, id: \.self) { days in
                                Toggle("За \(days) \(daysText(days))", isOn: Binding(
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
                                    Text("Удалить профиль")
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(profile == nil ? "Новый профиль" : "Редактировать профиль")
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
                    .disabled(name.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .sheet(isPresented: $showingDatePicker) {
                NavigationView {
                    DatePicker("Дата рождения", selection: $dateOfBirth, in: dateRange, displayedComponents: .date)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .navigationTitle("Дата рождения")
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
            .alert("Удалить профиль?", isPresented: $showingDeleteAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Удалить", role: .destructive) {
                    deleteProfile()
                }
            } message: {
                Text("Это действие нельзя отменить. Все данные профиля и подарки будут удалены.")
            }
            .onAppear {
                if let profile = profile {
                    name = profile.name
                    dateOfBirth = profile.dateOfBirth
                    notes = profile.notes
                    notificationsEnabled = profile.notificationsEnabled
                    selectedReminderDays = Set(profile.reminderDays)
                    photoPath = profile.photoPath
                    
                    if let photoPath = profile.photoPath {
                        selectedImage = ImageManager.shared.loadImage(from: photoPath)
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
            if let path = ImageManager.shared.saveImage(image, for: profileId) {
                savedPhotoPath = path
                
                // Удаляем старое фото если оно было
                if let oldPath = photoPath, oldPath != path {
                    ImageManager.shared.deleteImage(at: oldPath)
                }
            }
        }
        
        let reminderDaysArray = Array(selectedReminderDays).sorted()
        
        if let existingProfile = profile {
            // Обновляем существующий профиль
            var updatedProfile = existingProfile
            updatedProfile.name = name
            updatedProfile.dateOfBirth = dateOfBirth
            updatedProfile.notes = notes
            updatedProfile.notificationsEnabled = notificationsEnabled
            updatedProfile.reminderDays = reminderDaysArray
            updatedProfile.photoPath = savedPhotoPath
            
            dataManager.updateProfile(updatedProfile)
            notificationManager.updateNotifications(for: updatedProfile)
        } else {
            // Создаем новый профиль
            let newProfile = Profile(
                name: name,
                dateOfBirth: dateOfBirth,
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
            ImageManager.shared.deleteImage(at: photoPath)
        }
        
        // Удаляем профиль (это также удалит все подарки и уведомления)
        dataManager.deleteProfile(profile)
        
        dismiss()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    private func daysText(_ days: Int) -> String {
        switch days {
        case 1:
            return "день"
        case 3, 7, 14, 30:
            return "дней"
        default:
            return "дней"
        }
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

