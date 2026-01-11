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
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.clear]
            
            // Убираем верхний бордер (shadow)
            appearance.shadowColor = .clear
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
            
            // Для совместимости с iOS 12 и ниже
            UITabBar.appearance().shadowImage = UIImage()
        }
    }
}

