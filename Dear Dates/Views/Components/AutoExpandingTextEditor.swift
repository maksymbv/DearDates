//
//  AutoExpandingTextEditor.swift
//  DearDates
//
//  Created on 2025
//

import SwiftUI
import UIKit

struct AutoExpandingTextEditor: UIViewRepresentable {
    @Binding var text: String
    let maxLength: Int
    let placeholder: String
    var fixedWidth: CGFloat? = nil
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = false
        
        // Настройка переноса слов
        textView.textContainer.widthTracksTextView = true
        textView.textContainer.maximumNumberOfLines = 0
        textView.textContainer.lineBreakMode = .byWordWrapping
        
        // Устанавливаем constraint для фиксированной ширины если указана
        if let width = fixedWidth, width > 0 {
            textView.translatesAutoresizingMaskIntoConstraints = false
            textView.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        // Placeholder с форматированием
        if text.isEmpty {
            updatePlaceholderAttributes(textView)
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Обновляем constraint ширины если она изменилась
        if let width = fixedWidth, width > 0 {
            let widthConstraint = uiView.constraints.first { $0.firstAttribute == .width }
            if let constraint = widthConstraint {
                constraint.constant = width
            } else {
                uiView.translatesAutoresizingMaskIntoConstraints = false
                uiView.widthAnchor.constraint(equalToConstant: width).isActive = true
            }
        }
        
        // Обновляем только если текст изменился извне
        let currentText = uiView.text == placeholder ? "" : uiView.text ?? ""
        if currentText != text && !uiView.isFirstResponder {
            if text.isEmpty {
                updatePlaceholderAttributes(uiView)
            } else {
                uiView.textColor = .label
                uiView.text = text
                updateTextAttributes(uiView)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func updatePlaceholderAttributes(_ textView: UITextView) {
        let attributedString = NSMutableAttributedString(string: placeholder)
        let fullRange = NSRange(location: 0, length: placeholder.count)
        
        // Первая строка placeholder (до переноса строки) - крупнее
        if let newlineRange = placeholder.range(of: "\n") {
            let firstLineEnd = placeholder.distance(from: placeholder.startIndex, to: newlineRange.lowerBound)
            if firstLineEnd > 0 {
                // Стиль для первого параграфа (заголовок) - включает символ переноса строки
                let firstParagraphRange = NSRange(location: 0, length: firstLineEnd + 1)
                let titleFont = UIFont.preferredFont(forTextStyle: .title2)
                let titleParagraphStyle = NSMutableParagraphStyle()
                titleParagraphStyle.paragraphSpacing = 8 // Отступ после заголовка
                titleParagraphStyle.lineSpacing = 4
                
                attributedString.addAttribute(.font, value: titleFont, range: NSRange(location: 0, length: firstLineEnd))
                attributedString.addAttribute(.paragraphStyle, value: titleParagraphStyle, range: firstParagraphRange)
                
                // Стиль для остального текста (описание)
                let descriptionRange = NSRange(location: firstLineEnd + 1, length: placeholder.count - firstLineEnd - 1)
                let bodyFont = UIFont.preferredFont(forTextStyle: .body)
                let bodyParagraphStyle = NSMutableParagraphStyle()
                bodyParagraphStyle.lineSpacing = 4
                attributedString.addAttribute(.font, value: bodyFont, range: descriptionRange)
                attributedString.addAttribute(.paragraphStyle, value: bodyParagraphStyle, range: descriptionRange)
            }
        } else {
            // Если нет переноса, вся строка крупнее
            let titleFont = UIFont.preferredFont(forTextStyle: .title2)
            let titleParagraphStyle = NSMutableParagraphStyle()
            titleParagraphStyle.lineSpacing = 4
            attributedString.addAttribute(.font, value: titleFont, range: fullRange)
            attributedString.addAttribute(.paragraphStyle, value: titleParagraphStyle, range: fullRange)
        }
        
        // Цвет для всего placeholder
        attributedString.addAttribute(.foregroundColor, value: UIColor.placeholderText, range: fullRange)
        
        textView.attributedText = attributedString
    }
    
    private func updateTextAttributes(_ textView: UITextView) {
        guard !text.isEmpty, text != placeholder else {
            return
        }
        
        // Сохраняем позицию курсора перед обновлением
        let selectedRange = textView.selectedRange
        
        let attributedString = NSMutableAttributedString(string: text)
        let fullRange = NSRange(location: 0, length: text.count)
        
        // Находим первую строку (до первого переноса строки)
        if let newlineRange = text.range(of: "\n") {
            let firstLineEnd = text.distance(from: text.startIndex, to: newlineRange.lowerBound)
            if firstLineEnd > 0 {
                // Стиль для первого параграфа (заголовок) - включает символ переноса строки
                let firstParagraphRange = NSRange(location: 0, length: firstLineEnd + 1)
                let titleFont = UIFont.preferredFont(forTextStyle: .title2)
                let boldFont = titleFont.bold()
                let titleParagraphStyle = NSMutableParagraphStyle()
                titleParagraphStyle.paragraphSpacing = 8 // Отступ после заголовка
                titleParagraphStyle.lineSpacing = 4
                
                attributedString.addAttribute(.font, value: boldFont, range: NSRange(location: 0, length: firstLineEnd))
                attributedString.addAttribute(.paragraphStyle, value: titleParagraphStyle, range: firstParagraphRange)
                
                // Стиль для остального текста (описание)
                let descriptionRange = NSRange(location: firstLineEnd + 1, length: text.count - firstLineEnd - 1)
                let bodyFont = UIFont.preferredFont(forTextStyle: .body)
                let bodyParagraphStyle = NSMutableParagraphStyle()
                bodyParagraphStyle.lineSpacing = 4
                attributedString.addAttribute(.font, value: bodyFont, range: descriptionRange)
                attributedString.addAttribute(.paragraphStyle, value: bodyParagraphStyle, range: descriptionRange)
            }
        } else {
            // Если нет переноса строки, вся строка - заголовок (жирная и крупная)
            let titleFont = UIFont.preferredFont(forTextStyle: .title2)
            let boldFont = titleFont.bold()
            let titleParagraphStyle = NSMutableParagraphStyle()
            titleParagraphStyle.lineSpacing = 4
            attributedString.addAttribute(.font, value: boldFont, range: fullRange)
            attributedString.addAttribute(.paragraphStyle, value: titleParagraphStyle, range: fullRange)
        }
        
        // Цвет для всего текста
        attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: fullRange)
        
        textView.attributedText = attributedString
        
        // Восстанавливаем позицию курсора после обновления
        // Проверяем, что сохраненная позиция все еще валидна
        let maxLocation = text.count
        if selectedRange.location <= maxLocation {
            let validRange = NSRange(
                location: min(selectedRange.location, maxLocation),
                length: min(selectedRange.length, maxLocation - min(selectedRange.location, maxLocation))
            )
            textView.selectedRange = validRange
        }
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: AutoExpandingTextEditor
        
        init(_ parent: AutoExpandingTextEditor) {
            self.parent = parent
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            // Убираем placeholder при начале редактирования
            if textView.text == parent.placeholder {
                textView.text = ""
                textView.textColor = .label
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            // Восстанавливаем placeholder если текст пустой
            if textView.text.isEmpty {
                parent.updatePlaceholderAttributes(textView)
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            let newText = textView.text ?? ""
            
            // Игнорируем placeholder
            guard newText != parent.placeholder else {
                parent.text = ""
                return
            }
            
            if newText.count <= parent.maxLength {
                textView.textColor = .label
                parent.text = newText
                parent.updateTextAttributes(textView)
            } else {
                // Откатываем изменение если превышен лимит
                let previousText = parent.text.isEmpty ? "" : parent.text
                if !previousText.isEmpty {
                    textView.text = previousText
                    parent.updateTextAttributes(textView)
                } else {
                    parent.updatePlaceholderAttributes(textView)
                }
            }
        }
    }
}

extension UIFont {
    func bold() -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(.traitBold) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: 0)
    }
}
