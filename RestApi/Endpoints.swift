//
//  Endpoints.swift
//  RestApi
//
//  Created by Keith Staines on 08/08/2023.
//

import Foundation

let baseURL = URL(string: "https://jsonplaceholder.typicode.com/")!

enum Endpoints: String {
    case posts
    case comments
    case albums
    case photos
    case todos
    case users
}
