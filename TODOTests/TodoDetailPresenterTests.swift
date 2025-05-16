//
//  TodoDetailPresenterTests.swift
//  TODO
//
//  Created by Katerina Ivanova on 15.05.2025.
//

import XCTest
@testable import TODO

class TodoDetailPresenterTests: XCTestCase {

    var sut: TodoDetailPresenter!
    var mockInteractor: MockTodoDetailInteractor!
    var mockRouter: MockTodoDetailRouter!
    var mockView: MockTodoDetailView!
    var mockOutput: MockTodoListModuleOutput!

    let existingTodo = Todo(id: 1, todo: "Existing", completed: false, body: "Existing Body")

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockInteractor = MockTodoDetailInteractor()
        mockRouter = MockTodoDetailRouter()
        mockView = MockTodoDetailView()
        mockOutput = MockTodoListModuleOutput()
    }

    override func tearDownWithError() throws {
        sut = nil
        mockInteractor = nil
        mockRouter = nil
        mockView = nil
        mockOutput = nil
        try super.tearDownWithError()
    }

    func setupPresenter(todo: Todo?, isNewTodo: Bool) {
        sut = TodoDetailPresenter(
            interactor: mockInteractor,
            router: mockRouter,
            view: mockView,
            todo: todo,
            output: mockOutput,
            isNewTodo: isNewTodo
        )
    }

    func testAddTodo_callsOutput() {
        setupPresenter(todo: nil, isNewTodo: true)
        let title = "New Task"
        let body = "New Body"

        sut.addTodo(title: title, body: body)

        XCTAssertEqual(mockOutput.addNewTodoCalledWith?.title, title)
        XCTAssertEqual(mockOutput.addNewTodoCalledWith?.body, body)
        XCTAssertFalse(mockInteractor.editTodoCalled)
    }

    func testEditTodo_success_callsOutputAndRefreshes() {
        setupPresenter(todo: existingTodo, isNewTodo: false)
        let newTitle = "Updated Title"
        let newBody = "Updated Body"
        let updatedTodoFromInteractor = Todo(id: existingTodo.id, todo: newTitle, completed: false, body: newBody)
        mockInteractor.editTodoResult = .success(updatedTodoFromInteractor)
        
        let expectation = XCTestExpectation(description: "Edit todo success")

        sut.editTodo(title: newTitle, body: newBody)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.mockInteractor.editTodoCalled)
            XCTAssertEqual(self.mockInteractor.lastEditedTodoInfo?.id, self.existingTodo.id)
            XCTAssertEqual(self.mockInteractor.lastEditedTodoInfo?.title, newTitle)
            XCTAssertEqual(self.mockInteractor.lastEditedTodoInfo?.body, newBody)
            
            XCTAssertEqual(self.mockOutput.refreshUpdatedTodoCalledWith?.id, updatedTodoFromInteractor.id)
            XCTAssertEqual(self.mockOutput.refreshUpdatedTodoCalledWith?.todo, updatedTodoFromInteractor.todo)
            XCTAssertNil(self.mockOutput.addNewTodoCalledWith)
            XCTAssertFalse(self.mockView.showErrorCalled)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testEditTodo_failure_showsError() {
        setupPresenter(todo: existingTodo, isNewTodo: false)
        let newTitle = "Updated Title"
        let newBody = "Updated Body"
        mockInteractor.editTodoResult = .failure(.updateFailed(NSError(domain: "test", code: 1)))
        
        let expectation = XCTestExpectation(description: "Edit todo failure")

        sut.editTodo(title: newTitle, body: newBody)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.mockInteractor.editTodoCalled)
            XCTAssertTrue(self.mockView.showErrorCalled)
            XCTAssertNotNil(self.mockView.errorTitle)
            XCTAssertNil(self.mockOutput.refreshUpdatedTodoCalledWith)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testEditTodo_whenTodoIsNil_doesNothing() {
        setupPresenter(todo: nil, isNewTodo: false)
        sut.editTodo(title: "Some", body: "Thing")
        XCTAssertFalse(mockInteractor.editTodoCalled)
        XCTAssertNil(mockOutput.refreshUpdatedTodoCalledWith)
    }

    func testOnBackButtonTapped_callsRouter() {
        setupPresenter(todo: nil, isNewTodo: true)
        sut.onBackButtonTapped()
        XCTAssertTrue(mockRouter.popToToDoListCalled)
    }
}
