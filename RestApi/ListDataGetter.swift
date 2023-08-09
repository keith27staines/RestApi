//
//  ListDataGetter.swift
//  RestApi
//
//  Created by Keith Staines on 09/08/2023.
//

import Foundation

class ListDataGetter<T> where T: ListAdaptable & Decodable {
    let service: GenericService<T>

    init(endPoint: Endpoint) {
        let performer = ServicePerformer()
        self.service = GenericService(endpoint: endPoint, servicePerformer: performer)
    }
    
    func getAll(completion: @escaping (Result<[ListDisplayable], ServiceError>) -> Void) {
        service.getAll { result in
            switch result {
            case .success(let items):
                completion(.success(items.adaptToListDisplayable()))
            case .failure(let serviceError):
                completion(.failure(serviceError))
            }
        }
    }
}
