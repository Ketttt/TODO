//
//  TodoListRouter.swift
//  TODO
//
//  Created by Katerina Ivanova on 08.05.2025.
//

import UIKit

protocol ITodoListRouter: AnyObject {
    func openTodoDetail(todo: Todo?, output: TodoListModuleInput, isNewTodo: Bool)
}

final class TodoListRouter {
    
    weak var viewController: UIViewController?
    
    init(_ nav: UIViewController?) {
        self.viewController = nav
    }
}

extension TodoListRouter: ITodoListRouter {
    func openTodoDetail(todo: Todo?, output: TodoListModuleInput, isNewTodo: Bool) {
        guard let navigation = viewController?.navigationController else { return }
        let todoDetail = TodoDetailAssembly().makeModule(todo: todo, output: output, isNewTodo: isNewTodo)
        navigation.pushViewController(todoDetail, animated: true)
    }
}
