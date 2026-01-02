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
    
    init(text: Binding<String>, maxLength: Int, height: CGFloat) {
        self._text = text
        self.maxLength = maxLength
        self.height = height
    }
    
    var body: some View {
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
