//
//  ContentView.swift
//  DearDates
//
//  Created on 2025
//

import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var selectedTab = 0
    @State private var showingAddProfile = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ListView()
                .tabItem {
                    Label("", systemImage: "list.bullet")
                }
                .tag(0)
            
            CalendarView()
                .tabItem {
                    Label("", systemImage: "calendar")
                }
                .tag(1)
            
            // Пустой таб для кнопки добавления
            Color.clear
                .tabItem {
                    Label("", systemImage: "plus.circle.fill")
                }
                .tag(2)
            
            SearchView()
                .tabItem {
                    Label("", systemImage: "magnifyingglass")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("", systemImage: "gearshape")
                }
                .tag(4)
        }
        .sheet(isPresented: $showingAddProfile) {
            AddEditProfileView()
        }
        .preferredColorScheme(settingsManager.themeType.colorScheme)
        .accentColor(settingsManager.accentColor == .pink ? .pink : .blue)
        .onChange(of: selectedTab) { oldValue, newTab in
            if newTab == 2 {
                showingAddProfile = true
            }
        }
        .onChange(of: showingAddProfile) { oldValue, newValue in
            if !newValue && selectedTab == 2 {
                // Возвращаемся на предыдущий таб после закрытия
                selectedTab = 0
            }
        }
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.clear]
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

