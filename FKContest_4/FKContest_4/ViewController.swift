//
//  ViewController.swift
//  FKContest_4
//
//  Created by Arthur Narimanov on 3/11/23.
//

import UIKit

class Model: Hashable {
    var isCheckmark: Bool = false
    let text: String
    init(_ text: String) {
        self.text = text
    }
    
    static func == (lhs: Model, rhs: Model) -> Bool {
        return lhs.text == rhs.text
    }
    
    func hash(into hasher: inout Hasher) {
        text.hash(into: &hasher)
    }
}

class ViewController: UIViewController {
    
    private var data: [Model] = []
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        table.delegate = self
        return table
    }()
    
    private lazy var diffableDataSource: UITableViewDiffableDataSource<Int, Model> = {
        return UITableViewDiffableDataSource<Int, Model>(
            tableView: tableView,
            cellProvider: { (tableView, indexPath, model) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
            cell.textLabel?.text = model.text
            cell.accessoryType = model.isCheckmark ? .checkmark : .none
            cell.selectionStyle = .none
            return cell
        })
    }()
    
    private var dataSourceSnapshot: NSDiffableDataSourceSnapshot<Int, Model>!
    
    override func loadView() {
        super.loadView()
        title = Constants.title
        navigationItem.rightBarButtonItem = configurBarButtonItem()
        view.addSubview(tableView)
        tableView.frame = view.bounds
        data = initialData()
        applySnapshot(for: data)
    }
    
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = diffableDataSource.itemIdentifier(for: indexPath),
        let first = dataSourceSnapshot.itemIdentifiers.first
        else {
            return
        }
        
        item.isCheckmark = tableView.cellForRow(at: indexPath)?.accessoryType != .checkmark
        if item.isCheckmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            if item != first {
                dataSourceSnapshot.moveItem(item, beforeItem: first)
                applySnapshot(for: dataSourceSnapshot.itemIdentifiers(inSection: Constants.section))
            }
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
    }
}

// MARK: - Private

private extension ViewController {
    enum Constants {
        static let section: Int = 0
        static let countItems: Int = 31
        static let title: String = "Task 4"
    }
    
    func configurBarButtonItem() -> UIBarButtonItem {
        return  UIBarButtonItem(
            title: "Shuffle",
            style: .plain,
            target: self,
            action: #selector(shuffle)
        )
    }
    
    @objc
    func shuffle() {
        applySnapshot(for: data.shuffled())
    }
    
    func applySnapshot(for data: [Model]) {
        dataSourceSnapshot = NSDiffableDataSourceSnapshot<Int, Model>()
        dataSourceSnapshot.appendSections([Constants.section])
        dataSourceSnapshot.appendItems(data, toSection: Constants.section)
        diffableDataSource.apply(dataSourceSnapshot, animatingDifferences: true)
    }
    
    func initialData() -> [Model]  {
        var item = 0
        var models: [Model] = []
        while (item != Constants.countItems) {
            models.append(Model(String(item)))
            item += 1
        }
        return models
    }
}
