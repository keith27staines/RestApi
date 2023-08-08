//
//  Services.swift
//  RestApi
//
//  Created by Keith Staines on 09/08/2023.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum ServiceError: Error {
    case unknownError
    case clientError(String)
    case httpError(Int)
    case decodingError
    case noData
}

class UserService {
    
    func fetchAll(completion: @escaping ([User]?,Error?) -> Void) {
        let endpoint = Endpoints.users.rawValue
        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            
            guard let self = self else { return }
            
            if let error = error {
                // some kind of connectivity issue
                completion(nil, ServiceError.clientError(error.localizedDescription))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                // a logical possibility but this will never happen in real life
                completion(nil, ServiceError.unknownError)
                return
            }
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                // server returned a failure error code
                completion(nil, ServiceError.httpError(httpResponse.statusCode))
                return
            }
            
            guard let data = data else {
                // the response from the server contained no data
                completion(nil, ServiceError.noData)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let users = try decoder.decode([User].self, from: data)
                completion(users, nil)
                return
            } catch {
                // the data could not be decoded into the data transfer object
                completion(nil, ServiceError.decodingError)
            }
        }
        
        // actually execute the task
        task.resume()
    }
}
