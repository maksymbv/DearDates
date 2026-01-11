//
//  LimitedTextEditor.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI
import Combine

struct LimitedTextEditor: View {
    @Binding var text: String
    let maxLength: Int
    let height: CGFloat
    let placeholder: String?
    
    init(text: Binding<String>, maxLength: Int, height: CGFloat, placeholder: String? = nil) {
        self._text = text
        self.maxLength = maxLength
        self.height = height
        self.placeholder = placeholder
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty, let placeholder = placeholder {
                Text(placeholder)
                    .foregroundColor(Color(.placeholderText))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 8)
                    .allowsHitTesting(false)
            }
            
            TextEditor(text: Binding(
                get: { text },
                set: { newValue in
                    if newValue.count <= maxLength {
                        text = newValue
                    }
                }
            ))
            .frame(height: height)
        }
    }
}
