//
//  TodoDetailRouter.swift
//  TODO
//
//  Created by Katerina Ivanova on 12.05.2025.
//

import UIKit

protocol ITodoDetailRouter {
    func popToToDoList()
}

final class TodoDetailRouter {
    
    var viewController: UIViewController?
    
    init(_ nav: UIViewController?) {
        self.viewController = nav
    }
}

extension TodoDetailRouter: ITodoDetailRouter {
    func popToToDoList() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
