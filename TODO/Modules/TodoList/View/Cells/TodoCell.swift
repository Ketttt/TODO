//
//  TodoCell.swift
//  TODO
//
//  Created by Katerina Ivanova on 08.05.2025.
//

import UIKit

final class TodoCell: UITableViewCell {
    
    var actionHandler: (() -> ())?
    private let contentViewWrapper = TodoContentView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(todo: Todo, isMenu: Bool) {
        contentViewWrapper.configure(todo: todo, isMenu: isMenu) { [weak self] in
            self?.actionHandler?()
        }
    }
}

private extension TodoCell {
    func setup() {
        contentView.addSubview(contentViewWrapper)
        contentViewWrapper.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            contentViewWrapper.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentViewWrapper.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentViewWrapper.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentViewWrapper.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}
