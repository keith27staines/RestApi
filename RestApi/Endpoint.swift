//
//  Endpoint.swift
//  RestApi
//
//  Created by Keith Staines on 08/08/2023.
//

import Foundation

//MARK: Talking point: I have used a bang! When is this justifiable in production code?
let baseURL = URL(string: "https://jsonplaceholder.typicode.com/")!

// MARK: Talking point: is an enum a good choice for endpoints?
enum Endpoint: String, CaseIterable {
    case posts
    case comments
    case albums
    case photos
    case todos
    case users
}
