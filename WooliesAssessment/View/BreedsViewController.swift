//
//  BreedsViewController.swift
//
//  Created by Hai Le Thanh.
//  Copyright © 2020 Hai Le Thanh. All rights reserved.
//
	

import UIKit

class BreedsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var viewModels: [BreedTableViewCellModel] = []
    var presenter: BreedsViewToPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        presenter?.fetchData()
    }
    
    // MARK: - Private
    private func setupViews() {
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(BreedTableViewCell.self)
    }
    
    @IBAction func sortOrderChanged(_ sender: UISegmentedControl) {
        presenter?.applySort(sender.selectedSegmentIndex == 0 ? .ascending : .descending)
    }
}

extension BreedsViewController: BreedsPresenterToViewProtocol {
    func displayData(_ viewModels: [BreedTableViewCellModel]) {
        self.viewModels.removeAll()
        self.viewModels.append(contentsOf: viewModels)
        tableView.reloadData()
    }
    
    func displayError(message: String) {
        
    }
}

extension BreedsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BreedTableViewCell = tableView.dequeueReuseableCell(indexPath: indexPath)
        cell.configure(with: viewModels[indexPath.row])
        presenter?.requestDataForCellIfNeeded(at: indexPath.row)
        return cell
    }
}
