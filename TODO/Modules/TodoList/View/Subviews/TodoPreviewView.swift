//
//  TodoPreviewView.swift
//  TODO
//
//  Created by Katerina Ivanova on 12.05.2025.
//

import UIKit

final class TodoPreviewView: UIView {
    
    private let contentContainer = UIView()
    private let contentView = TodoContentView()
    private var contentWidthConstraint: NSLayoutConstraint!
    
    init(todo: Todo) {
        super.init(frame: .zero)
        setupView()
        setupConstraints()
        configure(with: todo)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func calculatePreferredSize() -> CGSize {
        let targetWidth = effectiveScreenWidth - 40
        let fittingSize = contentContainer.systemLayoutSizeFitting(
            CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        return CGSize(width: targetWidth, height: min(fittingSize.height, 300))
    }
    
    private var effectiveScreenWidth: CGFloat {
          if let window = self.window {
              return window.bounds.width
          }
          
          if #available(iOS 15.0, *) {
              return UIApplication.shared.connectedScenes
                  .compactMap { $0 as? UIWindowScene }
                  .first?.screen.bounds.width ?? 390
          } else {
              return UIScreen.main.bounds.width
          }
      }
}

private extension TodoPreviewView {
    func setupConstraints() {
        
        let targetWidth = effectiveScreenWidth - 40
        contentWidthConstraint = contentContainer.widthAnchor.constraint(equalToConstant: targetWidth)
        
        NSLayoutConstraint.activate([
            contentContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentContainer.topAnchor.constraint(equalTo: topAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentWidthConstraint
        ])
        
        contentContainer.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor)
        ])
    }
    
    func setupView() {
        backgroundColor = .darkBackground
        layer.cornerRadius = Constants.Appearance.cornerRadius
        clipsToBounds = true
        addSubview(contentContainer)
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configure(with todo: Todo) {
        contentView.configure(todo: todo, isMenu: true, nil)
    }
}
