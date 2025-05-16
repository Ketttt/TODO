//
//  APIClientTests.swift
//  TODO
//
//  Created by Katerina Ivanova on 15.05.2025.
//

import XCTest
@testable import TODO

class APIClientTests: XCTestCase {

    var sut: APIClient!
    var mockNetworkService: MockNetworkService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockNetworkService = MockNetworkService()
        sut = APIClient(networkService: mockNetworkService)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockNetworkService = nil
        try super.tearDownWithError()
    }

    func testFetchTodos_whenNetworkAvailable_callsNetworkService() {
        MockNetworkMonitor._isConnected = true
        let expectation = XCTestExpectation(description: "Fetch todos calls network service")
        let expectedTodoList = TodoList(todos: [Todo(id: 1, todo: "API Todo", completed: false)], total: 1, skip: 0, limit: 1)
        mockNetworkService.requestResult = Result<TodoList, NetworkError>.success(expectedTodoList)

        sut.fetchTodos { result in
            switch result {
            case .success(let todoList):
                XCTAssertEqual(todoList.todos.count, 1)
                XCTAssertEqual(todoList.todos.first?.id, 1)
                XCTAssertTrue(self.mockNetworkService.requestCalled)
                XCTAssertTrue(self.mockNetworkService.lastEndpoint is TodoEndpoint)
                if let endpoint = self.mockNetworkService.lastEndpoint as? TodoEndpoint {
                    XCTAssertEqual(endpoint.path, "/todos")
                }
            case .failure:
                XCTFail("Fetch todos failed unexpectedly")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchTodos_whenNetworkServiceFails_propagatesError() {
        MockNetworkMonitor._isConnected = true
        let expectation = XCTestExpectation(description: "Fetch todos propagates network service error")
        let expectedError = NetworkError.serverError(statusCode: 500)
        mockNetworkService.requestResult = Result<TodoList, NetworkError>.failure(expectedError)

        sut.fetchTodos { result in
            switch result {
            case .success:
                XCTFail("Fetch todos succeeded unexpectedly")
            case .failure(let error):
                 XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                 XCTAssertTrue(self.mockNetworkService.requestCalled)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}
