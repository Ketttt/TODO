//
//  NetworkService.swift
//  TODO
//
//  Created by Katerina Ivanova on 08.05.2025.
//

import Foundation

protocol NetworkServiceProtocol {
    func request<T: Decodable>(endpoint: EndpointProtocol,
                               completion: @escaping (Result<T, NetworkError>) -> ())
}

final class NetworkService: NetworkServiceProtocol {
    
    private let queue: DispatchQueue
    private let session: URLSession
    
    init(queue: DispatchQueue = .global(qos: .utility),
         session: URLSession = .shared) {
        self.queue = queue
        self.session = session
    }
    
    func request<T: Decodable>(endpoint: EndpointProtocol, completion: @escaping (Result<T, NetworkError>) -> Void) {
        guard let urlRequest = endpoint.urlRequest else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        queue.async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async {
                    completion(.failure(.unknownError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "NetworkService was deallocated"]))))
                }
                return
            }
            self.session.dataTask(with: urlRequest.logOutgoingRequest()) { data, response, error in
                
                urlRequest.logIncomingResponse(data: data, response: response as? HTTPURLResponse, error: error)
                
                let result: Result<T, NetworkError> = self.processResponse(
                    data: data,
                    response: response,
                    error: error
                ) as Result<T, NetworkError>
                
                DispatchQueue.main.async {
                    completion(result)
                }
            }.resume()
        }
    }
    
    private func processResponse<T: Decodable>(
        data: Data?,
        response: URLResponse?,
        error: Error?
    ) -> Result<T, NetworkError> {
        if let error = error {
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    return .failure(.noInternetConnection)
                default:
                    return .failure(.networkError(urlError))
                }
            }
            return .failure(.unknownError(error))
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(.invalidResponse)
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            break
        case 400:
            return .failure(.badRequest)
        case 404:
            return .failure(.notFound)
        case 500...599:
            return .failure(.serverError(statusCode: httpResponse.statusCode))
        default:
            return .failure(.httpError(statusCode: httpResponse.statusCode))
        }
        
        guard let data = data else {
            return .failure(.noData)
        }
        
        do {
            let decodedObject = try JSONDecoder().decode(T.self, from: data)
            return .success(decodedObject)
        } catch let decodingError as DecodingError {
            return .failure(.decodingFailed(decodingError))
        } catch {
            return .failure(.unknownError(error))
        }
    }
}
