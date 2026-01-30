//
//  ContentView.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("selectedTab") private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ListView()
                .tabItem {
                    Label("", systemImage: "person.2.fill")
                }
                .tag(0)
            
            CalendarView()
                .tabItem {
                    Label("", systemImage: "calendar")
                }
                .tag(1)
        }
        .preferredColorScheme(settingsManager.themeType.colorScheme)
        .accentColor(settingsManager.accentColor.color)
        .onAppear {
            setupAppearance()
            // Очищаем badge при открытии главного экрана
            NotificationManager.shared.clearBadge()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NavigateToMainTab"))) { _ in
            selectedTab = 0
        }
    }
    
    private func setupAppearance() {
        // Настройка Tab Bar - эффект матового стекла
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        tabBarAppearance.backgroundEffect = blurEffect
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.clear]
        tabBarAppearance.shadowColor = .clear
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().isTranslucent = true
        
        // Navigation Bar - прозрачный
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        navBarAppearance.backgroundColor = .clear
        navBarAppearance.backgroundEffect = nil
        navBarAppearance.shadowColor = .clear
        navBarAppearance.shadowImage = UIImage()
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().shadowImage = UIImage()
    }
    
}

