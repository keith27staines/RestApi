//
//  ListViewController.swift
//  RestApi
//
//  Created by Keith Staines on 09/08/2023.
//

import UIKit

class ListViewController<T>: UITableViewController where T: ListAdaptable & Decodable {
    
    private let cellIdentifier = "ListDisplayableCell"
    private (set) var listDataGetter: ListDataGetter<T>?
    private (set) var data = [ListDisplayable]()
    private let header: String

    init(listDataGetter: ListDataGetter<T>, endpoint: Endpoint) {
        self.listDataGetter = listDataGetter
        self.header = endpoint.rawValue.uppercased()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.header = ""
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        listDataGetter?.getAll(completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let list):
                data = list
            case .failure(let serviceError):
                print(serviceError.localizedDescription)
            }
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()

            }
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        header
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = data[indexPath.row].title
        contentConfiguration.secondaryText = data[indexPath.row].subtitle
        cell.contentConfiguration = contentConfiguration
        return cell
    }
}
