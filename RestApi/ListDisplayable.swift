//
//  ListDisplayable.swift
//  RestApi
//
//  Created by Keith Staines on 09/08/2023.
//

import Foundation

struct ListDisplayable {
    let id: Int
    let title: String
    let subtitle: String
}

protocol ListAdaptable {
    func adaptToListDisplayable() -> ListDisplayable
}

extension Post: ListAdaptable {
    func adaptToListDisplayable() -> ListDisplayable {
        ListDisplayable(
            id: id,
            title: title,
            subtitle: body
        )
    }
}

extension Comment: ListAdaptable {
    func adaptToListDisplayable() -> ListDisplayable {
        ListDisplayable(
            id: id,
            title: name,
            subtitle: body
        )
    }
}

extension Album: ListAdaptable {
    func adaptToListDisplayable() -> ListDisplayable {
        ListDisplayable(
            id: id,
            title: title,
            subtitle: ""
        )
    }
}

extension Photo: ListAdaptable {
    func adaptToListDisplayable() -> ListDisplayable {
        ListDisplayable(
            id: id,
            title: title,
            subtitle: ""
        )
    }
}

extension Todo: ListAdaptable {
    func adaptToListDisplayable() -> ListDisplayable {
        ListDisplayable(
            id: id,
            title: title,
            subtitle: completed ? "Completed" : "In progress"
        )
    }
}

extension User: ListAdaptable {
    func adaptToListDisplayable() -> ListDisplayable {
        ListDisplayable(
            id: id,
            title: name,
            subtitle: username
        )
    }
}

extension Array where Element: ListAdaptable {
    func adaptToListDisplayable() -> [ListDisplayable] {
        map { item in
            item.adaptToListDisplayable()
        }
    }
}

