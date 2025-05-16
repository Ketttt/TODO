//
//  MockNetworkMonitor.swift
//  TODO
//
//  Created by Katerina Ivanova on 15.05.2025.
//

@testable import TODO

class MockNetworkMonitor {
    static var _isConnected = true
    var isConnected: Bool { Self._isConnected }
    
    static func mockIsConnected(to value: Bool) {
        _isConnected = value
    }
}
