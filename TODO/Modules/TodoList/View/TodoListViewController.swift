//
//  TodoListViewController.swift
//  TODO
//
//  Created by Katerina Ivanova on 08.05.2025.
//

import UIKit

//MARK: - IToDoView Protocol
protocol ITodoListView: AnyObject {
    func showTodoList(_ todoList: [Todo])
    func showTodoAtRow(_ todo: Todo)
    func didDeleteTodo(_ todo: Todo)
    func refreshUpdatedTodo(todo: Todo)
    func addNewTodo(todo: Todo)
    func showSearchResults(_ todos: [Todo])
    func showError(title: String, message: String)
    func showLoading(_ isLoading: Bool)
}

final class TodoListViewController: UIViewController {
    
    //MARK: - Properties
    var presenter: ITodoListPresenter?
    private var todos: [Todo] = []
    private var filteredTodos: [Todo] = []
    private var currentTodos: [Todo] {
        searchController.isActive ? filteredTodos : todos
    }
    
    //MARK: - UI Elements
    private let bottomBar = BottomBarView()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .black
        tableView.register(TodoCell.self, forCellReuseIdentifier: "TodoCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск задач"
        searchController.searchBar.searchTextField.textColor = .white
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Поиск задач",
            attributes: [.foregroundColor: UIColor.lightGray]
        )
        searchController.searchBar.searchTextField.leftView?.tintColor = .lightGray
        searchController.searchBar.tintColor = .white
        searchController.searchBar.searchTextField.backgroundColor = UIColor.darkGray
        return searchController
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        setupUI()
        setupConstraints()
        setupSearchController()
        presenter?.loadTodos()
        setupTapGesture()
        searchController.searchBar.searchTextField.addTarget(
            self,
            action: #selector(searchTextChanged),
            for: .editingChanged
        )
    }
}

// MARK: - Private Methods
private extension TodoListViewController {
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        definesPresentationContext = true
    }
    
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    func configureNavBar() {
        title = "Задачи"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.hidesBarsOnSwipe = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.Margins.topPadding),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),
            
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: Constants.Sizes.bottomBarHeight)
        ])
    }
    
    func setupUI() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        view.backgroundColor = .black
        view.addSubviews(tableView, bottomBar, activityIndicator)
        tableView.delegate = self
        tableView.dataSource = self
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        view.safeAreaLayoutGuide.owningView?.backgroundColor = .darkBackground
        
        bottomBar.addButtonAction = { [weak self] in
            self?.presenter?.showTodoDetail(todo: nil, true)
        }
    }
    
    func editTodo(todo: Todo) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            if self.searchController.isActive {
                if let filteredIndex = self.filteredTodos.firstIndex(where: { $0.id == todo.id }) {
                    self.filteredTodos[filteredIndex] = todo
                    self.tableView.reloadRows(at: [IndexPath(row: filteredIndex, section: 0)], with: .fade)
                }
            } else {
                if let index = self.todos.firstIndex(where: { $0.id == todo.id }) {
                    self.todos[index] = todo
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                }
            }
        }
    }
}

// MARK: - Action Methods
extension TodoListViewController {
    
    @objc private func dismissKeyboard() {
        if searchController.isActive {
            searchController.searchBar.resignFirstResponder()
        } else {
            view.endEditing(true)
        }
    }
    
    @objc private func searchTextChanged() {
        searchController.searchBar.searchTextField.textColor = .white
    }
    
    @objc private func addTodoTapped() {
        presenter?.showTodoDetail(todo: nil, true)
    }
    
    @objc private func refreshData() {
        presenter?.loadTodos()
    }
}

//MARK: - UITableViewDelegate & UITableViewDataSource
extension TodoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentTodos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as? TodoCell else {
            return UITableViewCell()
        }
        
        let todo = currentTodos[indexPath.row]
        cell.selectionStyle = .none
        cell.configure(todo: todo, isMenu: false)
        cell.backgroundColor = .black
        cell.actionHandler = { [weak self] in
            guard let self else { return }
            let todo = self.currentTodos[indexPath.row]
            presenter?.checkButtonClicked(todo)
        }
        cell.configure(todo: todo, isMenu: false)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTodo = currentTodos[indexPath.row]
        presenter?.showTodoDetail(todo: selectedTodo, false)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completionHandler in
            guard let self = self else {
                completionHandler(false)
                return
            }
            let todo = currentTodos[indexPath.row]
            self.presenter?.deleteTodo(todo)
            completionHandler(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = UIColor.red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let todo = self.currentTodos[indexPath.item]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            return self.makePreviewViewController(for: todo)
        }) { [weak self] _ in
            
            guard let self = self else { return UIMenu() }
            
            let edit = UIAction(
                title: "Редактировать",
                image: UIImage(resource: .edit)
            ) { _ in
                self.presenter?.showTodoDetail(todo: todo, false)
            }
            
            let share = UIAction(title: "Поделиться",
                                 image: UIImage(resource: .export)
            ) { [weak self] _ in
                guard let self = self else { return }
                let shareText = """
                    Задача: \(todo.todo)
                    Описание: \(todo.body ?? "")
                    Статус: \(todo.completed ? "Выполнена" : "Не выполнена")
                    Дата: \(todo.date.formatted(date: .abbreviated, time: .omitted))
                    """
                let activityVC = UIActivityViewController(
                    activityItems: [shareText],
                    applicationActivities: nil
                )
                self.present(activityVC, animated: true)
            }
            
            let trash = UIAction(
                title: "Удалить",
                image: UIImage(resource: .trash)
            ) { _ in
                self.didDeleteTodo(todo)
            }
            let menu = UIMenu(title: "", children: [edit, share, trash])
            return menu
        }
    }
    
    private func makePreviewViewController(for todo: Todo) -> UIViewController {
        let previewVC = UIViewController()
        
        let previewView = TodoPreviewView(todo: todo)
        previewVC.view.addSubview(previewView)
        previewView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            previewView.leadingAnchor.constraint(equalTo: previewVC.view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: previewVC.view.trailingAnchor),
            previewView.topAnchor.constraint(equalTo: previewVC.view.topAnchor),
            previewView.bottomAnchor.constraint(equalTo: previewVC.view.bottomAnchor)
        ])
        
        previewVC.preferredContentSize = previewView.calculatePreferredSize()
        return previewVC
    }
}


//MARK: - ITodoListView
extension TodoListViewController: ITodoListView {
    func showLoading(_ isLoading: Bool) {
        if isLoading {
            if !tableView.refreshControl!.isRefreshing {
                activityIndicator.startAnimating()
            }
        } else {
            activityIndicator.stopAnimating()
            tableView.refreshControl?.endRefreshing()
        }
    }
    
    func showError(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(
            title: "OK",
            style: .default
        )
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
    
    func showSearchResults(_ todos: [Todo]) {
        self.filteredTodos = todos
        tableView.reloadData()
    }
    
    func didDeleteTodo(_ todo: Todo) {
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        UIView.animate(withDuration: 0.3) {
            self.todos.remove(at: index)
            if self.searchController.isActive {
                if let filteredIndex = self.filteredTodos.firstIndex(where: { $0.id == todo.id }) {
                    self.filteredTodos.remove(at: filteredIndex)
                    self.tableView.deleteRows(at: [IndexPath(row: filteredIndex, section: .zero)], with: .left)
                }
            } else {
                self.tableView.deleteRows(at: [IndexPath(row: index, section: .zero)], with: .left)
            }
        } completion: { _ in self.tableView.reloadData() }
        self.bottomBar.updateTodoCount(todos.count)
    }
    
    func showTodoAtRow(_ todo: Todo) {
        editTodo(todo: todo)
    }
    
    func showTodoList(_ todoList: [Todo]) {
        self.todos = todoList
        self.bottomBar.updateTodoCount(todos.count)
        self.tableView.reloadData()
    }
    
    func refreshUpdatedTodo(todo: Todo) {
        editTodo(todo: todo)
    }
    
    func addNewTodo(todo: Todo) {
        UIView.animate(withDuration: 0.3) {
            self.todos.insert(todo, at: 0)
            if self.searchController.isActive {
                self.filteredTodos.insert(todo, at: 0)
            }
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .right)
        } completion: { _ in self.tableView.reloadData() }
        self.bottomBar.updateTodoCount(todos.count)
    }
}

// MARK: - UISearchResultsUpdating
extension TodoListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        else { filteredTodos = []
            tableView.reloadData()
            return
        }
        
        if searchText.isEmpty {
            filteredTodos = todos
            tableView.reloadData()
        } else {
            presenter?.searchTodo(searchText: searchText)
        }
    }
}

// MARK: - UISearchControllerDelegate
extension TodoListViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        filteredTodos = todos
        tableView.reloadData()
    }
}
