//
//  MainViewController.swift
//  RestApi
//
//  Created by Keith Staines on 08/08/2023.
//

import UIKit

class MainViewController: UIViewController {
    
    lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(stack)
        stack.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stack.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true

        for endpoint in Endpoint.allCases {
            let button = makeButtonForEndpoint(endpoint)
            stack.addArrangedSubview(button)
        }
    }
    
    func makeButtonForEndpoint(_ endpoint: Endpoint) -> UIView {
        let action = UIAction { _ in
            self.presentListViewController(endpoint: endpoint)
        }
        let button = UIButton(primaryAction: action)
        button.setTitle(endpoint.rawValue, for: .normal)
        return button
    }
    
    func presentListViewController(endpoint: Endpoint) {
        show(MakeListViewControllerForEndpoint(endpoint), sender: self)
    }
    
    // MARK: Talking point:
    // The use of an enum to hold our endpoints is convenient but has a flaw:
    // Adding a new enpoint to the Enpoint enum means we will have to modify this
    // method too - breaking the open/closed principle.
    // Ideally, we ought to rethink our decision to use an enum for Endpoints,
    // but this has to be balanced against the convenience enums provide, and
    // how likely it is for new endpoints to be added (or removed).
    // I'll leave it as an exercise for anyone who wants to try this to replace
    // the endpoint enum with some other structure that allows for endpoints to
    // be added.
    func MakeListViewControllerForEndpoint(_ endpoint: Endpoint) -> UIViewController {
        let vc: UIViewController
        switch endpoint {
        case .posts:
            let dataGetter = ListDataGetter<Post>(endPoint: .posts)
            vc = ListViewController(listDataGetter: dataGetter, endpoint: .posts)
        case .comments:
            let dataGetter = ListDataGetter<Comment>(endPoint: .comments)
            vc = ListViewController(listDataGetter: dataGetter, endpoint: .comments)
        case .albums:
            let dataGetter = ListDataGetter<Album>(endPoint: .albums)
            vc = ListViewController(listDataGetter: dataGetter, endpoint: .albums)
        case .photos:
            let dataGetter = ListDataGetter<Photo>(endPoint: .photos)
            vc = ListViewController(listDataGetter: dataGetter, endpoint: .photos)
        case .todos:
            let dataGetter = ListDataGetter<Todo>(endPoint: .todos)
            vc = ListViewController(listDataGetter: dataGetter, endpoint: .todos)
        case .users:
            let dataGetter = ListDataGetter<User>(endPoint: .users)
            vc = ListViewController(listDataGetter: dataGetter, endpoint: .users)
        }
        return vc
    }
}

