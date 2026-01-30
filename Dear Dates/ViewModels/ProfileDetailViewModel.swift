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
    /// true, когда открыт дочерний экран (идея подарка/событие) — не показывать таб-бар в onDisappear
    @Published var navigatingToChild = false

    private let dataManager: DataManager
    private let notificationManager: NotificationManager
    
    init(
        dataManager: DataManager? = nil,
        notificationManager: NotificationManager? = nil
    ) {
        self.dataManager = dataManager ?? DataManager.shared
        self.notificationManager = notificationManager ?? NotificationManager.shared
    }
    
}

