//
//  TodoDetailViewController.swift
//  TODO
//
//  Created by Katerina Ivanova on 12.05.2025.
//

import UIKit

//MARK: - ITodoDetailView
protocol ITodoDetailView {
    func showError(title: String, message: String)
}

//MARK: - TodoDetailViewController
final class TodoDetailViewController: UIViewController {
    
    // MARK: - Properties
    var presenter: ITodoDetailPresenter?
    
    //MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    private let backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .black
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        return backgroundView
    }()
    
    private lazy var titleTextView = UITextView.makeTextView(fontSize: Constants.Text.title, isBold: true)
    private lazy var noteTextView = UITextView.makeTextView(fontSize: Constants.Text.mainSize, isBold: false)
    private lazy var dateLabel = UILabel.make(textColor: .darkGray, font: .systemFont(ofSize: 12), numberOfLines: 1, .left)
    private weak var activeTextView: UITextView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
    
// MARK: - Private Methods
private extension TodoDetailViewController {
    func configureNavBar() {
        let icon = UIImageView(image: .backIcon)
        icon.tintColor = .customYellow
        icon.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = "Назад"
        label.textColor = .customYellow
        label.font = UIFont.systemFont(ofSize: Constants.Text.system)
        
        let stackView = UIStackView(arrangedSubviews: [icon, label])
        stackView.axis = .horizontal
        stackView.spacing = Constants.Margins.navBackSpacing
        
        let backButton = UIBarButtonItem(customView: stackView)
        navigationItem.leftBarButtonItem = backButton
        navigationItem.largeTitleDisplayMode = .never
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onBack))
        stackView.isUserInteractionEnabled = true
        stackView.addGestureRecognizer(tapGesture)
    }
    
    func setupView() {
        view.backgroundColor = .black
        view.addSubview(backgroundView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubviews(titleTextView,
                                dateLabel,
                                noteTextView)
        
        setupLayout()
        registerKeyboardNotifications()
        setupGestures()
        setupTextView()
        configureNavBar()
    }
    
    func setupTextView() {
        titleTextView.delegate = self
        noteTextView.delegate = self
        
        if let date = presenter?.todo?.date {
            dateLabel.text = date.getFormattedDate(format: Constants.DateFormat.dateFormat)
        }
        
        if let todoText = presenter?.todo?.todo, !todoText.isEmpty {
            titleTextView.text = todoText
        } else {
            titleTextView.setPlaceholder(.visible("Enter title..."))
        }
        
        if let bodyText = presenter?.todo?.body, !bodyText.isEmpty {
            noteTextView.text = presenter?.todo?.body
        } else {
            noteTextView.setPlaceholder(.visible("Enter notes..."))
        }
    }
    
    func setupLayout() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Sizes.titleTextHeight),
            noteTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Sizes.noteTextHeight),
            
            titleTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Margins.navBackSpacing),
            titleTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: Constants.Margins.titleToDateSpacing),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Margins.leadingPadding),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Constants.Margins.trailingPadding),
            
            noteTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: Constants.Margins.topPadding),
            noteTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            noteTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            noteTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: Constants.Margins.bottomPadding)
        ])
    }
    
    func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Keyboard Notifications
    func registerKeyboardNotifications() {
        let keyboardNotifications: [(NSNotification.Name, Selector)] = [
            (UIResponder.keyboardWillShowNotification, #selector(adjustForKeyboard)),
            (UIResponder.keyboardWillHideNotification, #selector(adjustForKeyboard))
        ]
        
        for (notification, selector) in keyboardNotifications {
            NotificationCenter.default.addObserver(
                self, selector: selector, name: notification, object: nil
            )
        }
    }
}
    
// MARK: - Action Methods
extension TodoDetailViewController {
    
    @objc private func doneButtonTapped() {
        view.endEditing(true)
    }
    
    @objc private func handleTap() {
        view.endEditing(true)
    }
    
    @objc private func onBack() {
        
        let title = (titleTextView.textColor == .lightGray) ? nil : titleTextView.text.nilIfEmpty
        let body = (noteTextView.textColor == .lightGray) ? nil : noteTextView.text.nilIfEmpty
        
        guard title != nil || body != nil else { return }
        guard let isNewTodo = presenter?.isNewTodo else { return }
        
        if isNewTodo {
            presenter?.addTodo(title: title, body: body)
        } else {
            presenter?.editTodo(title: title, body: body)
        }
        presenter?.onBackButtonTapped()
    }
    
    @objc private func adjustForKeyboard(notification: NSNotification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        
        let keyboardHeight = notification.name == UIResponder.keyboardWillShowNotification ?
        keyboardFrame.height - view.safeAreaInsets.bottom : 0
        
        UIView.animate(withDuration: duration) {
            self.scrollView.contentInset.bottom = keyboardHeight
            self.scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
            
            if notification.name == UIResponder.keyboardWillShowNotification,
               let textView = self.activeTextView {
                let textViewFrame = textView.convert(textView.bounds, to: self.scrollView)
                self.scrollView.scrollRectToVisible(textViewFrame, animated: false)
            }
        }
    }
}

//MARK: - UITextViewDelegate
extension TodoDetailViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView
        
        if textView == titleTextView && textView.textColor == .lightGray {
            textView.setPlaceholder(.hidden)
            textView.textColor = .white
        } else if textView == noteTextView && textView.textColor == .lightGray {
            textView.setPlaceholder(.hidden)
            textView.textColor = .white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == titleTextView && textView.text.isEmpty {
            textView.setPlaceholder(.visible("Enter title..."))
            textView.textColor = .lightGray
        } else if textView == noteTextView && textView.text.isEmpty {
            textView.setPlaceholder(.visible("Enter notes..."))
            textView.textColor = .lightGray
        }
    }
}

//MARK: - ITodoDetailView
extension TodoDetailViewController: ITodoDetailView {
    func showError(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(
            title: "OK",
            style: .default
        )
        alert.addAction(okAction)
        
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true)
        }
    }
}
