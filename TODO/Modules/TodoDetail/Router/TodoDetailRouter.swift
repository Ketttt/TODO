//
//  TodoDetailRouter.swift
//  TODO
//
//  Created by Katerina Ivanova on 12.05.2025.
//

import UIKit

protocol ITodoDetailRouter: AnyObject {
    func popToToDoList()
}

final class TodoDetailRouter {
    
    weak var viewController: UIViewController?
    
    init(_ nav: UIViewController?) {
        self.viewController = nav
    }
}

extension TodoDetailRouter: ITodoDetailRouter {
    func popToToDoList() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
