//
//  ProfileHeaderView.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI
import SwiftData

struct ProfileHeaderView: View {
    let profile: Profile
    let avatarImage: UIImage?
    let locale: Locale
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                // Картинка профиля во всю ширину экрана (прямоугольник с увеличенной высотой)
                if let image = avatarImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.width / 0.75)
                        .clipped()
                        .overlay(
                            // Градиент для читаемости текста в нижней части
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.clear,
                                    Color.black.opacity(0.3)
                                ]),
                                startPoint: .center,
                                endPoint: .bottom
                            )
                            .frame(height: geometry.size.width / 0.75 * 0.4)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                        )
                } else {
                    // Если нет картинки, показываем градиент
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hue: profile.avatarColorHue, saturation: 0.7, brightness: 0.9),
                                    Color(hue: profile.avatarColorHue, saturation: 0.5, brightness: 0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: geometry.size.width, height: geometry.size.width / 0.75)
                        .overlay(
                            Text(profile.name.prefix(1).uppercased())
                                .font(.system(size: geometry.size.width * 0.4, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .overlay(
                            // Градиент для читаемости текста в нижней части
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.clear,
                                    Color.black.opacity(0.3)
                                ]),
                                startPoint: .center,
                                endPoint: .bottom
                            )
                            .frame(height: geometry.size.width / 0.75 * 0.4)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                        )
                }
                
                // Имя поверх фото снизу слева
                Text(profile.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            }
        }
        .aspectRatio(0.75, contentMode: .fit)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("accessibility.profile_header".localized + " \(profile.name)")
    }
}

