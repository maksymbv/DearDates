//
//  HighlightedText.swift
//  DearDates
//
//  Created on 2026
//

import SwiftUI

struct HighlightedText: View {
    let text: String
    let searchText: String
    let highlightColor: Color
    
    init(_ text: String, searchText: String, highlightColor: Color) {
        self.text = text
        self.searchText = searchText
        self.highlightColor = highlightColor
    }
    
    var body: some View {
        if searchText.isEmpty {
            Text(text)
        } else {
            Text(attributedString)
        }
    }
    
    private var attributedString: AttributedString {
        guard !searchText.isEmpty else {
            return AttributedString(text)
        }
        var attributedString = AttributedString(text)
        let searchLower = searchText.lowercased()
        let textLower = text.lowercased()
        
        // Используем NSString для более надежной работы с индексами
        let nsTextLower = NSString(string: textLower)
        let nsSearch = NSString(string: searchLower)
        
        var searchLocation = 0
        while searchLocation < nsTextLower.length {
            let range = nsTextLower.range(of: nsSearch as String, options: .caseInsensitive, range: NSRange(location: searchLocation, length: nsTextLower.length - searchLocation))
            
            if range.location == NSNotFound {
                break
            }
            
            // Преобразуем NSRange в Range<String.Index>
            if let swiftRange = Range(range, in: text) {
                // Конвертируем в диапазон AttributedString
                if let attributedRange = Range(swiftRange, in: attributedString) {
                    // Применяем только цвет для выделения - это достаточно заметно
                    attributedString[attributedRange].foregroundColor = highlightColor
                }
            }
            
            searchLocation = range.location + range.length
        }
        
        return attributedString
    }
}
