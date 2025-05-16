//
//  MockTodoListView.swift
//  TODO
//
//  Created by Katerina Ivanova on 15.05.2025.
//

@testable import TODO

class MockTodoListView: ITodoListView {
    var showTodoListCalledWith: [Todo]?
    var showTodoAtRowCalledWith: Todo?
    var didDeleteTodoCalledWith: Todo?
    var refreshUpdatedTodoCalledWith: Todo?
    var addNewTodoCalledWith: Todo?
    var showSearchResultsCalledWith: [Todo]?
    var showErrorCalledWith: (title: String, message: String)?
    
    var showLoadingHistory: [Bool] = []
    var showLoadingCalled: Bool { !showLoadingHistory.isEmpty }
    
    func showTodoList(_ todoList: [Todo]) { showTodoListCalledWith = todoList }
    func showTodoAtRow(_ todo: Todo) { showTodoAtRowCalledWith = todo }
    func didDeleteTodo(_ todo: Todo) { didDeleteTodoCalledWith = todo }
    func refreshUpdatedTodo(todo: Todo) { refreshUpdatedTodoCalledWith = todo }
    func addNewTodo(todo: Todo) { addNewTodoCalledWith = todo }
    func showSearchResults(_ todos: [Todo]) { showSearchResultsCalledWith = todos }
    func showError(title: String, message: String) { showErrorCalledWith = (title, message) }
    func showLoading(_ isLoading: Bool) { showLoadingHistory.append(isLoading) }
}
