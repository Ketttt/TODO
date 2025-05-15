//
//  AppError.swift
//  TODO
//
//  Created by Katerina Ivanova on 15.05.2025.
//

enum AppError: Error {
    case network(NetworkError)
    case coreData(CoreDataError)
    case validation(message: String)
    
    var title: String {
        switch self {
        case .network: return "Ошибка сети"
        case .coreData: return "Ошибка базы данных"
        case .validation: return "Ошибка валидации"
        }
    }
    
    var message: String {
        switch self {
        case .network(let error):
            return error.alertMessage
        case .coreData(let error):
            return error.alertMessage
        case .validation(let message):
            return message
        }
    }
}
