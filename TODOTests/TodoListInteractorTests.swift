//
//  TodoDetailPresenterTests.swift
//  TODO
//
//  Created by Katerina Ivanova on 15.05.2025.
//

import XCTest
@testable import TODO

class TodoListInteractorTests: XCTestCase {

    var sut: TodoListInteractor!
    var mockAPIClient: MockAPIClient!
    var mockCoreDataManager: MockCoreDataManager!
    var userDefaults: UserDefaults!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockAPIClient = MockAPIClient()
        mockCoreDataManager = MockCoreDataManager()
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)

        sut = TodoListInteractor(apiClient: mockAPIClient, coreDataManager: mockCoreDataManager)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockAPIClient = nil
        mockCoreDataManager = nil
        userDefaults.removePersistentDomain(forName: #file)
        userDefaults = nil
        try super.tearDownWithError()
    }

    func setIsFirstLaunch(_ value: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(!value, forKey: "hasLaunchedBefore")
        defaults.synchronize()
        print("Manually set isFirstLaunch to", !value)
    }
    private func getIsFirstLaunch() -> Bool {
        !userDefaults.bool(forKey: "hasLaunchedBefore")
    }


    func testFetchTodoList_firstLaunch_networkSuccess_savesAndFetchesFromCoreData() {
           setIsFirstLaunch(true)
           MockNetworkMonitor._isConnected = true
   
           let expectation = XCTestExpectation(description: "Fetch from network, save, then fetch from CoreData")
           let networkTodos = [Todo(id: 1, todo: "Network Todo", completed: false)]
           let coreDataTodosAfterSave = [Todo(id: 1, todo: "Network Todo", completed: false)]
   
           mockAPIClient.fetchTodosResult = .success(TodoList(todos: networkTodos, total: 1, skip: 0, limit: 1))
           mockCoreDataManager.saveTodosResult = .success(())
           mockCoreDataManager.fetchTodoListResult = .success(coreDataTodosAfterSave)
   
           sut.fetchTodoList { result in
               switch result {
               case .success(let todos):
                   XCTAssertEqual(todos.count, 1)
                   XCTAssertEqual(todos.first?.todo, "Network Todo")
                   XCTAssertTrue(self.mockAPIClient.fetchTodosCalled)
                   XCTAssertTrue(self.mockCoreDataManager.saveTodosCalled)
                   XCTAssertTrue(self.mockCoreDataManager.fetchTodoListCalled)
               case .failure(let error):
                   XCTFail("Fetch failed: \(error)")
               }
               expectation.fulfill()
           }
           wait(for: [expectation], timeout: 1.0)
       }

    func testAPIClientCalledWhenFirstLaunchAndOnline() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "hasLaunchedBefore")
        setIsFirstLaunch(true)
        
        MockNetworkMonitor._isConnected = true
        mockAPIClient.fetchTodosResult = .failure(NetworkError.serverError(statusCode: 500))
        mockCoreDataManager.fetchTodoListResult = .success([])
        
        let expectation = XCTestExpectation(description: "Completion should be called")
        sut.fetchTodoList { _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(mockAPIClient.fetchTodosCalled, "APIClient должен быть вызван")
        XCTAssertTrue(UserDefaults.standard.isFirstLaunch, "isFirstLaunch должен остаться true")
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "hasLaunchedBefore")
        super.tearDown()
    }
    override func setUp() {
        userDefaults = UserDefaults(suiteName: "TestDefaults")!
            sut = TodoListInteractor(apiClient: mockAPIClient,
                                   coreDataManager: mockCoreDataManager)
        }
  
    


    func testFetchTodoList_notFirstLaunch_fetchesFromCoreData() {
        setIsFirstLaunch(false)
        MockNetworkMonitor._isConnected = true

        let expectation = XCTestExpectation(description: "Fetch from CoreData (not first launch)")
        let coreDataTodos = [Todo(id: 3, todo: "Existing CoreData Todo", completed: false)]
        mockCoreDataManager.fetchTodoListResult = .success(coreDataTodos)

        sut.fetchTodoList { result in
            switch result {
            case .success(let todos):
                XCTAssertEqual(todos.count, 1)
                XCTAssertEqual(todos.first?.todo, "Existing CoreData Todo")
                XCTAssertFalse(self.mockAPIClient.fetchTodosCalled)
                XCTAssertTrue(self.mockCoreDataManager.fetchTodoListCalled)
            case .failure(let error):
                XCTFail("Fetch failed: \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchTodoList_noInternet_fetchesFromCoreData() {
        setIsFirstLaunch(true)
        UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        MockNetworkMonitor._isConnected = false

        let expectation = XCTestExpectation(description: "Fetch from CoreData (no internet)")
        let coreDataTodos = [Todo(id: 4, todo: "Offline CoreData Todo", completed: true)]
        mockCoreDataManager.fetchTodoListResult = .success(coreDataTodos)

        sut.fetchTodoList { result in
            switch result {
            case .success(let todos):
                XCTAssertEqual(todos.count, 1)
                XCTAssertEqual(todos.first?.todo, "Offline CoreData Todo")
                XCTAssertFalse(self.mockAPIClient.fetchTodosCalled)
                XCTAssertTrue(self.mockCoreDataManager.fetchTodoListCalled)
            case .failure(let error):
                XCTFail("Fetch failed: \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        UserDefaults.standard.removeObject(forKey: "hasLaunchedBefore")
    }

    func testChangeTaskStatus_delegatesToCoreDataManager() {
        let expectation = XCTestExpectation(description: "Change task status delegates")
        let todoId: Int64 = 123
        let expectedTodo = Todo(id: todoId, todo: "Task", completed: true)
        mockCoreDataManager.changeTaskStatusResult = .success(expectedTodo)

        sut.changeTaskStatus(for: todoId) { result in
            if case .success(let todo) = result {
                XCTAssertEqual(todo.id, expectedTodo.id)
                XCTAssertTrue(self.mockCoreDataManager.changeTaskStatusCalled)
            } else {
                XCTFail("Change task status failed")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDeleteTodo_delegatesToCoreDataManager() {
        let expectation = XCTestExpectation(description: "Delete todo delegates")
        let todoId: Int64 = 456
        let expectedTodo = Todo(id: todoId, todo: "To Delete", completed: false)
        mockCoreDataManager.deleteTodoResult = .success(expectedTodo)

        sut.deleteTodo(for: todoId) { result in
            if case .success(let todo) = result {
                XCTAssertEqual(todo.id, expectedTodo.id)
                XCTAssertTrue(self.mockCoreDataManager.deleteTodoCalled)
            } else {
                XCTFail("Delete todo failed")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testAddTodo_delegatesToCoreDataManager() {
        let expectation = XCTestExpectation(description: "Add todo delegates")
        let title = "New Task"
        let body = "New Body"
        let expectedTodo = Todo(id: 789, todo: title, completed: false, body: body)
        mockCoreDataManager.addTodoResult = .success(expectedTodo)

        sut.addTodo(title: title, body: body) { result in
            if case .success(let todo) = result {
                XCTAssertEqual(todo.todo, title)
                XCTAssertEqual(todo.body, body)
                XCTAssertTrue(self.mockCoreDataManager.addTodoCalled)
            } else {
                XCTFail("Add todo failed")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchTodo_delegatesToCoreDataManager() {
        let expectation = XCTestExpectation(description: "Search todo delegates")
        let searchText = "find me"
        let foundTodos = [Todo(id: 111, todo: "Found Item", completed: false)]
        mockCoreDataManager.searchTodoResult = .success(foundTodos)

        sut.searchTodo(with: searchText) { result in
            if case .success(let todos) = result {
                XCTAssertEqual(todos.count, 1)
                XCTAssertEqual(todos.first?.todo, "Found Item")
                XCTAssertTrue(self.mockCoreDataManager.searchTodoCalled)
                XCTAssertEqual(self.mockCoreDataManager.lastSearchedText, searchText)
            } else {
                XCTFail("Search todo failed")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}
