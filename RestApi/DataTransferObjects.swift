//
//  DataTransferObjects.swift
//  RestApi
//
//  Created by Keith Staines on 08/08/2023.
//
// Data transfer objects compatible with the REST api
// available on
// https://jsonplaceholder.typicode.com
// Note that the User model contains only a subset of the fields held in the
// typicode database

struct Post: Codable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

struct Comment: Codable {
    let id: Int
    let postId: Int
    let name: String
    let email: String
    let body: String
}

struct Album: Codable {
    let id: Int
    let userId: Int
    let title: String
}

struct Photo: Codable {
    let id: Int
    let albumId: Int
    let title: String
    let url: String
    let thumbnail: String
}

struct Todo: Codable {
    let id: Int
    let userId: Int
    let title: String
    let completed: Bool
}

/// Very basic user model, many fields omitted because I am lazy
struct User: Codable {
    let id: Int
    let name: String
    let username: String
    let email: String
}

