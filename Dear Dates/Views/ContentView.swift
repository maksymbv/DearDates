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
    @State private var selectedTab = 0
    
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
            
            SearchView()
                .tabItem {
                    Label("", systemImage: "magnifyingglass")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("", systemImage: "gearshape")
                }
                .tag(3)
        }
        .preferredColorScheme(settingsManager.themeType.colorScheme)
        .accentColor(settingsManager.accentColor == .pink ? .pink : .blue)
        .onAppear {
            setupAppearance()
        }
    }
    
    private func setupAppearance() {
        // Настройка Tab Bar - используем тот же фон что и страницы
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemGroupedBackground
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.clear]
        
        // Убираем верхний бордер (shadow)
        tabBarAppearance.shadowColor = .clear
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Для совместимости с iOS 12 и ниже
        UITabBar.appearance().shadowImage = UIImage()
        
        // Navigation Bar - убираем разделитель, делаем прозрачным
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        navBarAppearance.shadowColor = .clear
        navBarAppearance.shadowImage = UIImage()
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = navBarAppearance
        
        // Делаем Navigation Bar прозрачным
        UINavigationBar.appearance().isTranslucent = true
        
        // Для совместимости с более старыми версиями iOS
        UINavigationBar.appearance().shadowImage = UIImage()
    }
    
}

