//
//  TodoContentView.swift
//  TODO
//
//  Created by Katerina Ivanova on 12.05.2025.
//

import UIKit

final class TodoContentView: UIView {
    // MARK: - Public Properties
    var actionHandler: (() -> ())?
    
    //MARK: - UI Elements
    private let todoTitle = UILabel.make(textColor: .white, font: .systemFont(ofSize: Constants.Text.mainSize), numberOfLines: 0)
    private let todoDescription = UILabel.make(textColor: .white, font: .systemFont(ofSize: 12), numberOfLines: 2, .justified)
    private let todoDate = UILabel.make(textColor: .darkGray, font: .systemFont(ofSize: 12), numberOfLines: 1)
    
    private lazy var checkBox: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(checkToDo), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var textStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [todoTitle, todoDescription, todoDate])
        stack.axis = .vertical
        stack.spacing = Constants.Margins.interlineSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var textLeadingConstraintWithCheckbox: NSLayoutConstraint!
    private var textLeadingConstraintWithoutCheckbox: NSLayoutConstraint!
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(todo: Todo, isMenu: Bool,_ actionHandler: (() -> Void)?) {
        self.actionHandler = actionHandler
        checkBox.isHidden = isMenu
        textLeadingConstraintWithCheckbox.isActive = !isMenu
        textLeadingConstraintWithoutCheckbox.isActive = isMenu
        
        todoDescription.text = todo.body
        todoDate.text = todo.date.getFormattedDate(format: Constants.DateFormat.dateFormat)
        
        if todo.completed {
            let attributed = NSAttributedString(
                string: todo.todo,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: UIColor.darkGray
                ]
            )
            todoTitle.attributedText = attributed
            todoDescription.textColor = .darkGray
        } else {
            todoTitle.attributedText = nil
            todoTitle.text = todo.todo
            todoTitle.textColor = .white
            todoDescription.textColor = .white
        }
        
        checkBox.setImage(UIImage(resource: todo.completed ? .doneIcon : .circle), for: .normal)
    }
    
    //MARK: - Action Methods
    @objc private func checkToDo() {
        actionHandler?()
    }
}

//MARK: - Private Methods
private extension TodoContentView {
    func setupViews() {
        addSubview(checkBox)
        addSubview(textStackView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            checkBox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Margins.leadingPadding),
            checkBox.topAnchor.constraint(equalTo: topAnchor, constant: Constants.Margins.topCellPadding),
            checkBox.widthAnchor.constraint(equalToConstant: Constants.Sizes.checkboxSize),
            checkBox.heightAnchor.constraint(equalToConstant: Constants.Sizes.checkboxSize),
            
            textStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Constants.Margins.trailingPadding),
            textStackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.Margins.topCellPadding),
            textStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Constants.Margins.bottomCellPadding)
        ])
        
        textLeadingConstraintWithCheckbox = textStackView.leadingAnchor.constraint(
            equalTo: checkBox.trailingAnchor,
            constant: Constants.Margins.iconToContentSpacing)
        textLeadingConstraintWithoutCheckbox = textStackView.leadingAnchor.constraint(
            equalTo: leadingAnchor,
            constant: Constants.Margins.leadingPadding)
        textLeadingConstraintWithCheckbox.isActive = true
    }
}
