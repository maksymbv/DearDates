//
//  AvatarView.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI

struct AvatarView: View {
    let image: UIImage?
    let name: String
    let avatarColorHue: Double
    let size: CGFloat
    @Environment(\.colorScheme) var colorScheme
    
    init(image: UIImage?, name: String, avatarColorHue: Double, size: CGFloat = 60) {
        self.image = image
        self.name = name
        self.avatarColorHue = avatarColorHue
        self.size = size
    }
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: max(size, 1), height: max(size, 1))
                    .clipped()
                    .clipShape(Circle())
                    .accessibilityLabel("accessibility.profile_photo".localized + " \(name)")
            } else {
                Circle()
                    .fill(Color.pastelColor(hue: avatarColorHue).opacity(colorScheme == .dark ? 0.6 : 0.7))
                    .frame(width: size, height: size)
                    .overlay(
                        Text(name.prefix(1).uppercased())
                            .font(size > 60 ? .system(size: 50) : .title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    )
                    .accessibilityLabel("accessibility.profile_avatar".localized + " \(name)")
            }
        }
    }
}
