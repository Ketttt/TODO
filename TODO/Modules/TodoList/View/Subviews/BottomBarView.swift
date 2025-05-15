//
//  BottomBarView.swift
//  TODO
//
//  Created by Katerina Ivanova on 08.05.2025.
//

import UIKit

final class BottomBarView: UIView {
    
    // MARK: - Public Properties
    var addButtonAction: (() -> Void)?
    
    //MARK: - UI Elements
    private let todoCountLabel = UILabel.make(textColor: .white, font: .systemFont(ofSize: 11), numberOfLines: 1, .center)
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "square.and.pencil", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.customYellow
        button.addTarget(self, action: #selector(handleAddButtonTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTodoCount(_ count: Int) {
        let localizedString = NSLocalizedString("TasksCount", comment: "")
        let result = String.localizedStringWithFormat(localizedString, count)
        todoCountLabel.text = result
    }
    
    //MARK: - Action Methods
    @objc private func handleAddButtonTap() {
        addButtonAction?()
    }
}

//MARK: - Private Methods
private extension BottomBarView {
    func setupView() {
        backgroundColor = .darkBackground
        addSubviews(todoCountLabel, addButton)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            todoCountLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            todoCountLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            addButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: Constants.Margins.trailingPadding),
            addButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
