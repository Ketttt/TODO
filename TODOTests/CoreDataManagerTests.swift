//
//  CoreDataManagerTests.swift
//  TODO
//
//  Created by Katerina Ivanova on 15.05.2025.
//

import XCTest
import CoreData
@testable import TODO

class CoreDataManagerTests: XCTestCase {

    var coreDataManager: CoreDataManager!
    var mockPersistentContainer: NSPersistentContainer!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockPersistentContainer = NSPersistentContainer(name: "TODO")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        mockPersistentContainer.persistentStoreDescriptions = [description]

        mockPersistentContainer.loadPersistentStores { (description, error) in
            XCTAssertNil(error, "Failed to load in-memory persistent store: \(error?.localizedDescription ?? "Unknown error")")
        }
        coreDataManager = CoreDataManager(context: mockPersistentContainer.viewContext)
    }

    override func tearDownWithError() throws {
        coreDataManager = nil
        mockPersistentContainer = nil
        try super.tearDownWithError()
    }

    func testAddTodo_ShouldSaveAndReturnTodo() {
        let expectation = XCTestExpectation(description: "Add todo completion")
        let title = "Test Todo"
        let body = "Test Body"

        coreDataManager.addTodo(title: title, body: body) { result in
            switch result {
            case .success(let todo):
                XCTAssertEqual(todo.todo, title)
                XCTAssertEqual(todo.body, body)
                XCTAssertFalse(todo.completed)
                self.coreDataManager.fetchTodoList { fetchResult in
                    switch fetchResult {
                    case .success(let todos):
                        XCTAssertEqual(todos.count, 1)
                        XCTAssertEqual(todos.first?.todo, title)
                    case .failure(let error):
                        XCTFail("Fetch failed: \(error)")
                    }
                    expectation.fulfill()
                }
            case .failure(let error):
                XCTFail("Add failed: \(error)")
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchTodoList_WhenEmpty_ShouldReturnEmptyArray() {
        let expectation = XCTestExpectation(description: "Fetch todo list completion")
        coreDataManager.fetchTodoList { result in
            switch result {
            case .success(let todos):
                XCTAssertTrue(todos.isEmpty)
            case .failure(let error):
                XCTFail("Fetch failed: \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSaveTodos_ShouldStoreMultipleTodos() {
        let expectation = XCTestExpectation(description: "Save multiple todos completion")
        let todosToSave = [
            Todo(id: 1, todo: "Todo 1", completed: false, body: "Body 1"),
            Todo(id: 2, todo: "Todo 2", completed: true, body: "Body 2")
        ]

        coreDataManager.saveTodos(todosToSave) { result in
            switch result {
            case .success:
                self.coreDataManager.fetchTodoList { fetchResult in
                    switch fetchResult {
                    case .success(let fetchedTodos):
                        XCTAssertEqual(fetchedTodos.count, 2)
                        XCTAssertTrue(fetchedTodos.contains(where: { $0.id == 1 }))
                        XCTAssertTrue(fetchedTodos.contains(where: { $0.id == 2 }))
                    case .failure(let error):
                        XCTFail("Fetch after save failed: \(error)")
                    }
                    expectation.fulfill()
                }
            case .failure(let error):
                XCTFail("Save todos failed: \(error)")
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testChangeTaskStatus_ShouldToggleCompletedState() {
        let expectation = XCTestExpectation(description: "Change task status completion")
        let initialTodo = Todo(id: 10, todo: "Status Todo", completed: false, body: "Status Body")
        
        coreDataManager.saveTodos([initialTodo]) { saveResult in
            guard case .success = saveResult else {
                XCTFail("Initial save failed"); expectation.fulfill(); return
            }
            
            self.coreDataManager.changeTaskStatus(for: initialTodo.id) { result in
                switch result {
                case .success(let updatedTodo):
                    XCTAssertEqual(updatedTodo.id, initialTodo.id)
                    XCTAssertTrue(updatedTodo.completed)
                case .failure(let error):
                    XCTFail("Change status failed: \(error)")
                }
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testDeleteTodo_ShouldRemoveTodo() {
        let expectation = XCTestExpectation(description: "Delete todo completion")
        let todoToDelete = Todo(id: 20, todo: "Delete Me", completed: false, body: "Body")

        coreDataManager.saveTodos([todoToDelete]) { saveResult in
            guard case .success = saveResult else {
                XCTFail("Initial save for delete failed"); expectation.fulfill(); return
            }
            self.coreDataManager.deleteTodo(for: todoToDelete.id) { deleteResult in
                switch deleteResult {
                case .success(let deletedTodo):
                    XCTAssertEqual(deletedTodo.id, todoToDelete.id)
                    self.coreDataManager.fetchTodoList { fetchResult in
                        if case .success(let todos) = fetchResult {
                            XCTAssertFalse(todos.contains(where: { $0.id == todoToDelete.id }))
                        } else {
                            XCTFail("Fetch after delete failed")
                        }
                        expectation.fulfill()
                    }
                case .failure(let error):
                    XCTFail("Delete failed: \(error)")
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testEditTodo_ShouldUpdateTitleAndBody() {
        let expectation = XCTestExpectation(description: "Edit todo completion")
        let originalTodo = Todo(id: 30, todo: "Original Title", completed: false, body: "Original Body")
        let newTitle = "Updated Title"
        let newBody = "Updated Body"

        coreDataManager.saveTodos([originalTodo]) { saveResult in
            guard case .success = saveResult else {
                XCTFail("Initial save for edit failed"); expectation.fulfill(); return
            }
            self.coreDataManager.editTodo(id: originalTodo.id, title: newTitle, body: newBody) { editResult in
                switch editResult {
                case .success(let editedTodo):
                    XCTAssertEqual(editedTodo.id, originalTodo.id)
                    XCTAssertEqual(editedTodo.todo, newTitle)
                    XCTAssertEqual(editedTodo.body, newBody)
                    XCTAssertEqual(editedTodo.completed, originalTodo.completed)
                case .failure(let error):
                    XCTFail("Edit failed: \(error)")
                }
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testSearchTodo_ShouldReturnMatchingTodos() {
        let expectation = XCTestExpectation(description: "Search todo completion")
        let todosToSearch = [
            Todo(id: 101, todo: "Apple Pie", completed: false, body: "Sweet dessert"),
            Todo(id: 102, todo: "Banana Bread", completed: true, body: "Tasty snack"),
            Todo(id: 103, todo: "Orange Juice", completed: false, body: "Refreshing apple drink")
        ]
        coreDataManager.saveTodos(todosToSearch) { saveResult in
            guard case .success = saveResult else {
                XCTFail("Initial save for search failed"); expectation.fulfill(); return
            }
            self.coreDataManager.searchTodo(with: "apple") { searchResult in
                switch searchResult {
                case .success(let foundTodos):
                    XCTAssertEqual(foundTodos.count, 2)
                    XCTAssertTrue(foundTodos.contains(where: { $0.id == 101 }))
                    XCTAssertTrue(foundTodos.contains(where: { $0.id == 103 }))
                case .failure(let error):
                    XCTFail("Search failed: \(error)")
                }
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchTodo_WithEmptyText_ShouldReturnEmptyArray() {
        let expectation = XCTestExpectation(description: "Search todo with empty text")
        coreDataManager.searchTodo(with: "") { result in
            switch result {
            case .success(let todos):
                XCTAssertTrue(todos.isEmpty, "Expected empty array for empty search text")
            case .failure(let error):
                XCTFail("Search failed: \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}
