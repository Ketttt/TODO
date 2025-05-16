//
//  TodoListPresenterTests.swift
//  TODO
//
//  Created by Katerina Ivanova on 15.05.2025.
//

import XCTest
@testable import TODO

class TodoListPresenterTests: XCTestCase {

    var sut: TodoListPresenter!
    var mockInteractor: MockTodoListInteractor!
    var mockRouter: MockTodoListRouter!
    var mockView: MockTodoListView!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockInteractor = MockTodoListInteractor()
        mockRouter = MockTodoListRouter()
        mockView = MockTodoListView()
        sut = TodoListPresenter(interactor: mockInteractor, router: mockRouter, view: mockView)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockInteractor = nil
        mockRouter = nil
        mockView = nil
        try super.tearDownWithError()
    }

    func testLoadTodos_success_showsLoadingAndTodoList() {
        let todos = [Todo(id: 1, todo: "Test", completed: false)]
        mockInteractor.fetchTodoListResult = .success(todos)

        sut.loadTodos()

        XCTAssertTrue(mockInteractor.fetchTodoListCalled)
        XCTAssertTrue(mockView.showLoadingCalled)
        XCTAssertEqual(mockView.showLoadingHistory, [true, false])
        XCTAssertEqual(mockView.showTodoListCalledWith?.count, 1)
        XCTAssertEqual(mockView.showTodoListCalledWith?.first?.id, 1)
        XCTAssertNil(mockView.showErrorCalledWith)
    }

    func testLoadTodos_failure_showsLoadingAndError() {
        mockInteractor.fetchTodoListResult = .failure(.network(.noInternetConnection))

        sut.loadTodos()

        XCTAssertTrue(mockInteractor.fetchTodoListCalled)
        XCTAssertTrue(mockView.showLoadingCalled)
        XCTAssertEqual(mockView.showLoadingHistory, [true, false])
        XCTAssertNotNil(mockView.showErrorCalledWith)
        XCTAssertEqual(mockView.showErrorCalledWith?.title, "Ошибка сети")
        XCTAssertNil(mockView.showTodoListCalledWith)
    }

    func testCheckButtonClicked_success_updatesView() {
        let todoToUpdate = Todo(id: 1, todo: "Task", completed: false)
        let updatedTodo = Todo(id: 1, todo: "Task", completed: true)
        mockInteractor.changeTaskStatusResult = .success(updatedTodo)

        sut.checkButtonClicked(todoToUpdate)

        XCTAssertTrue(mockInteractor.changeTaskStatusCalled)
        XCTAssertEqual(mockView.showTodoAtRowCalledWith?.id, updatedTodo.id)
        XCTAssertEqual(mockView.showTodoAtRowCalledWith?.completed, updatedTodo.completed)
        XCTAssertNil(mockView.showErrorCalledWith)
    }
    
    func testCheckButtonClicked_failure_showsError() {
        let todoToUpdate = Todo(id: 1, todo: "Task", completed: false)
        mockInteractor.changeTaskStatusResult = .failure(.updateFailed(NSError(domain: "test", code: 1)))

        sut.checkButtonClicked(todoToUpdate)

        XCTAssertTrue(mockInteractor.changeTaskStatusCalled)
        XCTAssertNotNil(mockView.showErrorCalledWith)
        XCTAssertNil(mockView.showTodoAtRowCalledWith)
    }

    func testDeleteTodo_success_updatesView() {
        let todoToDelete = Todo(id: 1, todo: "Delete", completed: false)
        mockInteractor.deleteTodoResult = .success(todoToDelete)

        sut.deleteTodo(todoToDelete)

        XCTAssertTrue(mockInteractor.deleteTodoCalled)
        XCTAssertEqual(mockView.didDeleteTodoCalledWith?.id, todoToDelete.id)
        XCTAssertNil(mockView.showErrorCalledWith)
    }

    func testDeleteTodo_failure_showsError() {
        let todoToDelete = Todo(id: 1, todo: "Delete", completed: false)
        mockInteractor.deleteTodoResult = .failure(.deleteFailed(NSError(domain: "test", code: 1)))

        sut.deleteTodo(todoToDelete)
        
        XCTAssertTrue(mockInteractor.deleteTodoCalled)
        XCTAssertNotNil(mockView.showErrorCalledWith)
        XCTAssertNil(mockView.didDeleteTodoCalledWith)
    }

    func testShowTodoDetail_forNewTodo_callsRouter() {
        sut.showTodoDetail(todo: nil, true)
        XCTAssertTrue(mockRouter.openTodoDetailCalled)
        XCTAssertNil(mockRouter.openTodoDetailTodo)
        XCTAssertTrue(mockRouter.openTodoDetailIsNewTodo ?? false)
    }

    func testShowTodoDetail_forExistingTodo_callsRouter() {
        let existingTodo = Todo(id: 1, todo: "Existing", completed: false)
        sut.showTodoDetail(todo: existingTodo, false)

        XCTAssertTrue(mockRouter.openTodoDetailCalled)
        XCTAssertEqual(mockRouter.openTodoDetailTodo?.id, existingTodo.id)
        XCTAssertFalse(mockRouter.openTodoDetailIsNewTodo ?? true)
    }
    
    func testSearchTodo_success_showsSearchResults() {
        let searchText = "query"
        let searchResults = [Todo(id: 1, todo: "Found by search", completed: false)]
        mockInteractor.searchTodoResult = .success(searchResults)
        
        let expectation = XCTestExpectation(description: "Search todo completion")
        mockInteractor.searchTodoResult = .success(searchResults)
        
        sut.searchTodo(searchText: searchText)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.mockInteractor.searchTodoCalled)
            XCTAssertEqual(self.mockInteractor.lastSearchedText, searchText)
            XCTAssertEqual(self.mockView.showSearchResultsCalledWith?.count, searchResults.count)
            XCTAssertEqual(self.mockView.showSearchResultsCalledWith?.first?.id, searchResults.first?.id)
            XCTAssertNil(self.mockView.showErrorCalledWith)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchTodo_failure_showsError() {
        let searchText = "query"
        mockInteractor.searchTodoResult = .failure(.searchTodoFailed)
        
        let expectation = XCTestExpectation(description: "Search todo failure completion")
        
        sut.searchTodo(searchText: searchText)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.mockInteractor.searchTodoCalled)
            XCTAssertEqual(self.mockInteractor.lastSearchedText, searchText)
            XCTAssertNotNil(self.mockView.showErrorCalledWith)
            XCTAssertNil(self.mockView.showSearchResultsCalledWith)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - TodoListModuleInput Tests
    func testAddNewTodo_success_updatesView() {
        let title = "New via Input"
        let body = "Body via Input"
        let newTodo = Todo(id: 99, todo: title, completed: false, body: body)
        mockInteractor.addTodoResult = .success(newTodo)
        
        let expectation = XCTestExpectation(description: "Add new todo via input completion")

        sut.addNewTodo(title: title, body: body)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.mockInteractor.addTodoCalled)
            XCTAssertEqual(self.mockInteractor.lastAddedTodoInfo?.title, title)
            XCTAssertEqual(self.mockInteractor.lastAddedTodoInfo?.body, body)
            XCTAssertEqual(self.mockView.addNewTodoCalledWith?.id, newTodo.id)
            XCTAssertNil(self.mockView.showErrorCalledWith)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRefreshUpdatedTodo_updatesView() {
        let updatedTodo = Todo(id: 101, todo: "Refreshed", completed: true)
        let expectation = XCTestExpectation(description: "Refresh updated todo completion")

        sut.refreshUpdatedTodo(todo: updatedTodo)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.mockView.refreshUpdatedTodoCalledWith?.id, updatedTodo.id)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}
