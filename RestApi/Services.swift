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

// MARK: First attempt!
// This is ugly code. It works correctly but it is begging to be
// refactored. Try counting the code smells :)
class NotDryUserService {

    func getAll(completion: @escaping ([User]?,ServiceError?) -> Void) {
        
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

// MARK: Adding support for a another endpoint
// Folowing the existing pattern, adding support for another endpoint duplicates
// involves duplicating a lot of ugly code. If it wasn't obvious before, it is
// now: It's high time we did some refactoring.
class NotDryCommentService {

    func fetchAll(completion: @escaping ([Comment]?,ServiceError?) -> Void) {
        
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
// This is a somewhat better attempt, using generics makes the code much DRYer.
// We have spotted that the two previous services are almost identical except for
// the types they use. That is the key smell that shouts "use generics"
// This new attempt does that and improves things, still contains some ugliness
// and adds new ungliness of its own:
// 1. The completion handler returns a type (tuple) that is hard to handle
// 2. We have introduced a horrible switch over types, which breaks
//    the Open/Closed principle and, in this implementation, the Liskov
//    substitution principle
class BadGenericService {
    
    func getAll<DTO: Decodable>(completion: @escaping ([DTO]?, Error?) -> Void) {
        let endpoint: String
        
        // HORROR - switching on the type. If you find yourself doing this, it
        // almost always means your design could be improved
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
            fatalError() // HORROR of HORRORS!
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
// Here, by injecting the endpoint, a whole bunch of ugliness is removed.
// We have also clarified how clients should (now, must) use the completion handler
// by returning a generic Result<> object
// And we have made a first step in respecting the Single responsibility
// principle by factoring out the code to build a request, but there is still a
// lot more we could do here (we could and probably should factor out HTTP status
// handling and json decoding for example, which would make the code much more
// testable).
class ServicePerformer {
    
    func performGetAll<DTO: Decodable>(endpoint: Endpoint, completion: @escaping (Result<[DTO], ServiceError>) -> Void) {
        
        let request = buildRequest(endpoint: endpoint)
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
    
    func buildRequest(endpoint: Endpoint) -> URLRequest {
        let url = baseURL.appendingPathComponent(endpoint.rawValue)
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}

// MARK: with the request permformer factored out, the service classes are small and easily testable, which is great... but there are also a lot of them, all doing more or less the same thing, which is not so great :(

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

// MARK: Ah, heck, way too many in fact. There must be a better way! (and there is)
// Let's make a single service that can be used for all endpoints
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
