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
    case put = "PUT"
    case delete = "DELETE"
}

enum ServiceError: Error {
    case unexpectedError
    case clientError(String)
    case httpError(Int)
    case decodingError
    case noData
}

class NotDryUserService {
    
    func getAll(completion: @escaping ([User]?,Error?) -> Void) {
        let endpoint = Endpoint.users.rawValue
        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
                        
            if let error = error {
                // some kind of connectivity issue
                completion(nil, ServiceError.clientError(error.localizedDescription))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                // a logical possibility but this will never happen in real life
                completion(nil, ServiceError.unexpectedError)
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

class NotDryCommentService {
    
    func fetchAll(completion: @escaping ([Comment]?,Error?) -> Void) {
        let endpoint = Endpoint.users.rawValue
        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            
            if let error = error {
                // some kind of connectivity issue
                completion(nil, ServiceError.clientError(error.localizedDescription))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                // a logical possibility but this will never happen in real life
                completion(nil, ServiceError.unexpectedError)
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
                let comments = try decoder.decode([Comment].self, from: data)
                completion(comments, nil)
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


// MARK: GenericService
class BadGenericService {
    
    func getAll<DTO: Decodable>(completion: @escaping ([DTO]?, Error?) -> Void) {
        let endpoint: String
        switch DTO.self {
        case is User.Type:
            endpoint = Endpoint.users.rawValue
        case is Comment.Type:
            endpoint = Endpoint.comments.rawValue
        case is Post.Type:
            endpoint = Endpoint.posts.rawValue
        case is Album.Type:
            endpoint = Endpoint.albums.rawValue
        case is Photo.Type:
            endpoint = Endpoint.photos.rawValue
        case is Todo.Type:
            endpoint = Endpoint.todos.rawValue
        default:
            fatalError()
        }
        
        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            
            if let error = error {
                // some kind of connectivity issue
                completion(nil, ServiceError.clientError(error.localizedDescription))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                // a logical possibility but this will never happen in real life
                completion(nil, ServiceError.unexpectedError)
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
                let users = try decoder.decode([DTO].self, from: data)
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

// MARK: Factored out the thing that actually performs a generic request
class ServicePerformer {
    
    func performGetAll<DTO: Decodable>(endpoint: Endpoint, completion: @escaping (Result<[DTO], ServiceError>) -> Void) {
        
        let url = baseURL.appendingPathComponent(endpoint.rawValue)
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            
            if let error = error {
                // some kind of connectivity issue
                completion(.failure(ServiceError.clientError(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                // a logical possibility but this will never happen in real life
                completion(.failure(.unexpectedError))
                return
            }
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                // server returned a failure error code
                completion(.failure(.httpError(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                // the response from the server contained no data
                completion(.failure(.noData))
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let users = try decoder.decode([DTO].self, from: data)
                completion(.success(users))
                return
            } catch {
                // the data could not be decoded into the data transfer object
                completion(.failure(.decodingError))
            }
        }
        
        // actually execute the task
        task.resume()
    }
}

class PostsService {
    private let servicePerformer: ServicePerformer
    private let endpoint = Endpoint.posts
    
    init(servicePerformer: ServicePerformer) {
        self.servicePerformer = servicePerformer
    }
    
    func getAll(completion: @escaping (Result<[Post],ServiceError>) -> Void) {
        servicePerformer.performGetAll(endpoint: endpoint, completion: completion)
    }
}

class CommentService {
    
    private let servicePerformer: ServicePerformer
    private let endpoint = Endpoint.comments
    
    init(servicePerformer: ServicePerformer) {
        self.servicePerformer = servicePerformer
    }
    
    func getAll(completion: @escaping (Result<[Comment],ServiceError>) -> Void) {
        servicePerformer.performGetAll(endpoint: endpoint, completion: completion)
    }
}

class AlbumsService {
    private let servicePerformer: ServicePerformer
    private let endpoint = Endpoint.albums
    
    init(servicePerformer: ServicePerformer) {
        self.servicePerformer = servicePerformer
    }
    
    func getAll(completion: @escaping (Result<[Album],ServiceError>) -> Void) {
        servicePerformer.performGetAll(endpoint: endpoint, completion: completion)
    }
}

class PhotosService {
    private let servicePerformer: ServicePerformer
    private let endpoint = Endpoint.photos
    
    init(servicePerformer: ServicePerformer) {
        self.servicePerformer = servicePerformer
    }
    
    func getAll(completion: @escaping (Result<[Photo],ServiceError>) -> Void) {
        servicePerformer.performGetAll(endpoint: endpoint, completion: completion)
    }
}

class TodosService {
    private let servicePerformer: ServicePerformer
    private let endpoint = Endpoint.todos
    
    init(servicePerformer: ServicePerformer) {
        self.servicePerformer = servicePerformer
    }
    
    func getAll(completion: @escaping (Result<[Todo],ServiceError>) -> Void) {
        servicePerformer.performGetAll(endpoint: endpoint, completion: completion)
    }
}

class UsersService {
    
    private let servicePerformer: ServicePerformer
    private let endpoint = Endpoint.users
    
    init(servicePerformer: ServicePerformer) {
        self.servicePerformer = servicePerformer
    }
    
    func getAll(completion: @escaping (Result<[User],ServiceError>) -> Void) {
        servicePerformer.performGetAll(endpoint: endpoint, completion: completion)
    }
}

// MARK: Ah, heck, there must be a better way!

class GenericService<T> where T:ListAdaptable & Decodable {
    private let servicePerformer: ServicePerformer
    private let endpoint: Endpoint
    
    init(endpoint: Endpoint, servicePerformer: ServicePerformer) {
        self.servicePerformer = servicePerformer
        self.endpoint = endpoint
    }
    
    func getAll(completion: @escaping (Result<[T],ServiceError>) -> Void) {
        servicePerformer.performGetAll(endpoint: endpoint, completion: completion)
    }
}
