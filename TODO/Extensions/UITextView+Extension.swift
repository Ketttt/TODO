//
//  UITextView+Extension.swift
//  TODO
//
//  Created by Katerina Ivanova on 12.05.2025.
//

import UIKit

extension UITextView {
    enum PlaceholderState {
        case visible(String)
        case hidden
    }
    
    func setPlaceholder(_ state: PlaceholderState) {
        switch state {
        case .visible(let text):
            self.text = text
            self.textColor = .lightGray
        case .hidden:
            self.text = ""
            self.textColor = .white
        }
    }
    
    var isShowingPlaceholder: Bool {
        return textColor == .lightGray
    }
}

extension UITextView {
    static func makeTextView(fontSize: CGFloat, isBold: Bool) -> UITextView {
        let textView = UITextView()
        textView.textColor = .white
        textView.font = isBold ? .boldSystemFont(ofSize: fontSize) : .systemFont(ofSize: fontSize)
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }
}
