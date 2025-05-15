//
//  URLRequest+Extension.swift
//  TODO
//
//  Created by Katerina Ivanova on 08.05.2025.
//

import Foundation
import UIKit

extension URLRequest {
    func logOutgoingRequest() -> Self {
        let logMessage = RequestFormatter.outgoingRequestLog(self)
        print(logMessage)
        return self
    }
    
    func logIncomingResponse(data: Data?, response: HTTPURLResponse?, error: Error?) {
        let logMessage = RequestFormatter.incomingResponseLog(self, data: data, response: response, error: error)
        print(logMessage)
    }
}


private enum RequestFormatter {
    
    static func outgoingRequestLog(_ request: URLRequest) -> String {
        var log = "\n⬆️ [OUTGOING REQUEST]\n"
        log += request.url?.absoluteString.cyan ?? "No URL".red
        
        if let method = request.httpMethod, let url = request.url {
            log += "\n\(method.blue) \(url.path)"
            if let query = url.query {
                log += "?\(query)"
            }
        }
        
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            log += "\n\n🔠 [HEADERS]".white
            headers.forEach { key, value in
                log += "\n  \(key.cyan): \(value.white)"
            }
        }
        
        if let body = request.httpBody {
            log += "\n\n📦 [BODY]".white
            log += formatBody(body)
        }
        
        log += "\n\n----------------------------------------\n"
        return log
    }
    
    static func incomingResponseLog(_ request: URLRequest, data: Data?, response: HTTPURLResponse?, error: Error?) -> String {
        var log = "\n⬆️ [INCOMING RESPONSE]\n"
        log += request.url?.absoluteString.cyan ?? "No URL".red
        
        if let statusCode = response?.statusCode {
            let statusEmoji = statusCode >= 400 ? "❌" : "✅"
            let statusString = "HTTP \(statusCode) \(HTTPURLResponse.localizedString(forStatusCode: statusCode))"
            log += "\n\(statusEmoji) \(statusString.color(forStatusCode: statusCode))"
        }
        
        if let headers = response?.allHeaderFields as? [String: Any], !headers.isEmpty {
            log += "\n\n🔠 [HEADERS]".white
            headers.forEach { key, value in
                log += "\n  \(key.cyan): \(String(describing: value).white)"
            }
        }
        
        if let data = data {
            log += "\n\n📦 [BODY]".white
            log += formatBody(data)
        }
        
        if let error = error {
            log += "\n\n❗️ [ERROR]".red
            log += "\n\(error.localizedDescription.red)"
        }
        
        log += "\n\n----------------------------------------\n"
        return log
    }
    
    private static func formatBody(_ data: Data) -> String {
        guard !data.isEmpty else { return " Empty".gray }
        
        if let json = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            return "\n\(prettyString.green)"
        }
        
        if let string = String(data: data, encoding: .utf8) {
            return "\n\(string.white)"
        }
        
        return " Binary data (\(data.count) bytes)".gray
    }
}

// MARK: - String Coloring Utilities
private extension String {
    var red: String { colorize(.red) }
    var green: String { colorize(.green) }
    var blue: String { colorize(.blue) }
    var cyan: String { colorize(.cyan) }
    var white: String { colorize(.white) }
    var gray: String { colorize(.gray) }
    
    private func colorize(_ color: ANSIColor) -> String {
        return color.rawValue + self + ANSIColor.reset
    }
    
    func color(forStatusCode code: Int) -> String {
        switch code {
        case 200..<300: return green
        case 300..<400: return cyan
        case 400..<500: return yellow
        case 500..<600: return red
        default: return white
        }
    }
    
    private var yellow: String { colorize(.yellow) }
}

private enum ANSIColor: String {
    case red = "\u{001B}[31m"
    case green = "\u{001B}[32m"
    case blue = "\u{001B}[34m"
    case cyan = "\u{001B}[36m"
    case white = "\u{001B}[37m"
    case gray = "\u{001B}[90m"
    case yellow = "\u{001B}[33m"
    static let reset = "\u{001B}[0m"
}
