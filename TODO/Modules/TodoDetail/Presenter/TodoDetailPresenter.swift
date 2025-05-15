//
//  TodoDetailPresenter.swift
//  TODO
//
//  Created by Katerina Ivanova on 12.05.2025.
//

import Foundation

//MARK: - ITodoDetailPresenter
protocol ITodoDetailPresenter: AnyObject {
    var todo: Todo? { get set }
    var isNewTodo: Bool { get set }
    func onBackButtonTapped()
    func editTodo(title: String?, body: String?)
    func addTodo(title: String?, body: String?)
}

//MARK: - TodoDetailPresenter
final class TodoDetailPresenter {
    var interactor: ITodoDetailInteractor
    var router: ITodoDetailRouter
    var view: ITodoDetailView
    var todo: Todo?
    var output: TodoListModuleInput
    var isNewTodo: Bool
    
    init(interactor: ITodoDetailInteractor,
         router: ITodoDetailRouter,
         view: ITodoDetailView,
         todo: Todo?,
         output: TodoListModuleInput,
         isNewTodo: Bool) {
        self.interactor = interactor
        self.router = router
        self.view = view
        self.todo = todo
        self.output = output
        self.isNewTodo = isNewTodo
    }
}

extension TodoDetailPresenter: ITodoDetailPresenter {
    func addTodo(title: String?, body: String?) {
        self.output.addNewTodo(title: title, body: body)
    }
    
    func editTodo(title: String?, body: String?) {
        guard let id = self.todo?.id else { return }
        interactor.editTodo(id: id, title: title, body: body) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedTodo):
                    self?.output.refreshUpdatedTodo(todo: updatedTodo)
                case .failure(let error):
                    self?.view.showError(title: error.alertTitle, message: error.alertMessage)
                }
            }
        }
    }
    
    func onBackButtonTapped() {
        router.popToToDoList()
    }
}
