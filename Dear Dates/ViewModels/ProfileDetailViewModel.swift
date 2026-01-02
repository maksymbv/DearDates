//
//  ProfileDetailViewModel.swift
//  DearDates
//
//  Created on 2026
//

import Foundation
import SwiftData
import Combine

@MainActor
class ProfileDetailViewModel: ObservableObject {
    @Published var showingEditProfile = false
    @Published var showingAddGift = false
    @Published var showingEditGift: Gift? = nil
    @Published var showingAddEvent = false
    @Published var showingEditEvent: CustomEvent? = nil
    
    private let dataManager: DataManager
    private let notificationManager: NotificationManager
    
    init(
        dataManager: DataManager? = nil,
        notificationManager: NotificationManager? = nil
    ) {
        self.dataManager = dataManager ?? DataManager.shared
        self.notificationManager = notificationManager ?? NotificationManager.shared
    }
    
    func toggleFavorite(profile: Profile, context: ModelContext) {
        profile.isFavorite.toggle()
        profile.updatedAt = Date()
        dataManager.updateProfile(profile, notificationManager: notificationManager, context: context)
    }
}

