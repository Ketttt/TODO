//
//  CoreDataError.swift
//  TODO
//
//  Created by Katerina Ivanova on 15.05.2025.
//

enum CoreDataError: Error {
    case fetchFailed(Error? = nil)
    case objectNotFound(id: Any)
    case saveFailed(Error)
    case searchTodoFailed
    case updateFailed(Error)
    case deleteFailed(Error)
    case addFailed(Error)
}

extension CoreDataError: ErrorAlertConvertible {
    var alertTitle: String { return "Ошибка базы данных" }
    
    var alertMessage: String {
        switch self {
        case .fetchFailed(let error): return "Не удалось загрузить данные: \(error?.localizedDescription ?? "")"
        case .objectNotFound(let id): return "Объект с ID \(id) не найден"
        case .saveFailed(let error): return "Ошибка сохранения: \(error.localizedDescription)"
        case .searchTodoFailed: return "Не удалось найти задачу"
        case .updateFailed(let error): return "Ошибка обновления: \(error.localizedDescription)"
        case .deleteFailed(let error): return "Ошибка удаления: \(error.localizedDescription)"
        case .addFailed(let error): return "Ошибка добавления: \(error.localizedDescription)"
        }
    }
}
