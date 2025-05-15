//
//  TodoListPresenter.swift
//  TODO
//
//  Created by Katerina Ivanova on 08.05.2025.
//

import Foundation

protocol ITodoListPresenter: AnyObject {
    func loadTodos()
    func showTodoDetail(todo: Todo?,_ isNewTodo: Bool)
    func checkButtonClicked(_ todo: Todo)
    func deleteTodo(_ todo: Todo)
    func searchTodo(searchText: String)
}

final class TodoListPresenter {
    var interactor: ITodoListInteractor
    var router: ITodoListRouter
    weak var view: ITodoListView?
    
    init(interactor: ITodoListInteractor, router: ITodoListRouter, view: ITodoListView) {
        self.interactor = interactor
        self.router = router
        self.view = view
    }
}

//MARK: - ITodoListPresenter
extension TodoListPresenter: ITodoListPresenter {
    func loadTodos() {
        self.view?.showLoading(true)
        
        interactor.fetchTodoList { [weak self] result in
            guard let self = self else { return }
            self.view?.showLoading(false)
            
            switch result {
            case .success(let todoList):
                self.view?.showTodoList(todoList)
            case .failure(let error):
                self.view?.showError(title: error.title, message: error.message)
            }
        }
    }
    
    func checkButtonClicked(_ todo: Todo) {
        interactor.changeTaskStatus(for: todo.id) { [weak self] result in
            switch result {
            case .success(let success):
                self?.view?.showTodoAtRow(success)
            case .failure(let error):
                self?.view?.showError(title: error.alertTitle, message: error.alertMessage)
            }
        }
    }
    
    func deleteTodo(_ todo: Todo) {
        interactor.deleteTodo(for: todo.id) { [weak self] result in
            switch result {
            case .success(let deletedTodo):
                self?.view?.didDeleteTodo(deletedTodo)
            case .failure(let error):
                self?.view?.showError(title: error.alertTitle, message: error.alertMessage)
            }
        }
    }
    
    func searchTodo(searchText: String) {
        self.interactor.searchTodo(with: searchText) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let todos):
                    self?.view?.showSearchResults(todos)
                case .failure(let error):
                    self?.view?.showError(title: error.alertTitle, message: error.alertMessage)
                }
            }
        }
    }
    
    func showTodoDetail(todo: Todo?, _ isNewTodo: Bool) {
        router.openTodoDetail(todo: todo, output: self, isNewTodo: isNewTodo)
    }
}

//MARK: - TodoListModuleInput
extension TodoListPresenter: TodoListModuleInput {
    
    func addNewTodo(title: String?, body: String?) {
        interactor.addTodo(title: title, body: body) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let savedTodo):
                    self?.view?.addNewTodo(todo: savedTodo)
                case .failure(let error):
                    self?.view?.showError(title: error.alertTitle, message: error.alertMessage)
                }
            }
        }
    }
    
    func refreshUpdatedTodo(todo: Todo) {
        DispatchQueue.main.async { [weak self] in
            self?.view?.refreshUpdatedTodo(todo: todo)
        }
    }
}
