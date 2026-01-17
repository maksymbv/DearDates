//
//  OnboardingView.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.colorScheme) var colorScheme
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "onboarding.welcome.title",
            description: "onboarding.welcome.description",
            icon: "gift.fill"
        ),
        OnboardingPage(
            title: "onboarding.profiles.title",
            description: "onboarding.profiles.description",
            icon: "person.2.fill"
        ),
        OnboardingPage(
            title: "onboarding.gifts.title",
            description: "onboarding.gifts.description",
            icon: "sparkles"
        ),
        OnboardingPage(
            title: "onboarding.calendar.title",
            description: "onboarding.calendar.description",
            icon: "calendar"
        )
    ]
    
    var body: some View {
        ZStack {
            // Фон
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Контент
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                // Кнопки
                HStack(spacing: 20) {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation {
                                currentPage -= 1
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.primary)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                    } else {
                        Spacer()
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    if currentPage < pages.count - 1 {
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(settingsManager.accentColor.color)
                                .clipShape(Circle())
                        }
                    } else {
                        Button(action: {
                            // Последняя страница - закрываем onboarding
                            markOnboardingCompleted()
                            withAnimation {
                                isPresented = false
                            }
                        }) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(settingsManager.accentColor.color)
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func markOnboardingCompleted() {
        UserDefaults.standard.set(true, forKey: "OnboardingCompleted")
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let icon: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Иконка
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundColor(settingsManager.accentColor.color)
                .padding(.bottom, 20)
            
            // Заголовок
            Text(localizationManager.localizedString(page.title))
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            // Описание
            Text(localizationManager.localizedString(page.description))
                .font(.system(size: 18))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}

