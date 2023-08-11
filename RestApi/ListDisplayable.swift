//
//  ListDisplayable.swift
//  RestApi
//
//  Created by Keith Staines on 09/08/2023.
//

import Foundation

/// A struct that contains the data that can be displayed in a base UITableViewCell
struct ListDisplayable {
    let id: Int
    let title: String
    let subtitle: String
}

/// This protocol promises to adapt an instance of any of the DTO objects to a `ListDisplayable`
protocol ListAdaptable {
    func adaptToListDisplayable() -> ListDisplayable
}

/// Adapt `Post` to `ListDisplayable`
extension Post: ListAdaptable {
    func adaptToListDisplayable() -> ListDisplayable {
        ListDisplayable(
            id: id,
            title: title,
            subtitle: body
        )
    }
}

/// Adapt `Comment` to `ListDisplayable`
extension Comment: ListAdaptable {
    func adaptToListDisplayable() -> ListDisplayable {
        ListDisplayable(
            id: id,
            title: name,
            subtitle: body
        )
    }
}

/// Adapt `Album` to `ListDisplayable`
extension Album: ListAdaptable {
    func adaptToListDisplayable() -> ListDisplayable {
        ListDisplayable(
            id: id,
            title: title,
            subtitle: ""
        )
    }
}

/// Adapt `Photo` to `ListDisplayable`
extension Photo: ListAdaptable {
    func adaptToListDisplayable() -> ListDisplayable {
        ListDisplayable(
            id: id,
            title: title,
            subtitle: ""
        )
    }
}

/// Adapt `Todo` to `ListDisplayable`
extension Todo: ListAdaptable {
    func adaptToListDisplayable() -> ListDisplayable {
        ListDisplayable(
            id: id,
            title: title,
            subtitle: completed ? "Completed" : "In progress"
        )
    }
}

/// Adapt `User` to `ListDisplayable`
extension User: ListAdaptable {
    func adaptToListDisplayable() -> ListDisplayable {
        ListDisplayable(
            id: id,
            title: name,
            subtitle: username
        )
    }
}

/// Adapt an entire array of `ListAdaptable` elements to an array of `ListDisplayable` objects
extension Array where Element: ListAdaptable {
    func adaptToListDisplayable() -> [ListDisplayable] {
        map { item in
            item.adaptToListDisplayable()
        }
    }
}

