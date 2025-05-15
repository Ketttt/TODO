//
//  NetworkError.swift
//  TODO
//
//  Created by Katerina Ivanova on 08.05.2025.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingFailed(Error)
    case noInternetConnection
    case networkError(URLError)
    case unknownError(Error)
    case invalidResponse
    case badRequest
    case notFound
    case serverError(statusCode: Int)
    case httpError(statusCode: Int)
}

extension NetworkError: ErrorAlertConvertible {
    var alertTitle: String { return "Ошибка сети" }
    
    var alertMessage: String {
        switch self {
        case .invalidURL: return "Некорректный URL"
        case .noData: return "Данные не получены"
        case .decodingFailed(let error): return "Ошибка декодирования: \(error.localizedDescription)"
        case .noInternetConnection: return "Нет интернет-соединения"
        case .networkError(let error): return  "Ошибка сети: \(error.localizedDescription)"
        case .unknownError(let error): return "Неизвестная ошибка: \(error.localizedDescription)"
        case .invalidResponse: return "Неверный ответ сервера"
        case .badRequest: return "Неверный запрос (400)"
        case .notFound: return "Не найдено (404)"
        case .serverError(let code): return "Ошибка сервера (\(code))"
        case .httpError(let code): return "HTTP error (\(code))"
        }
    }
}
