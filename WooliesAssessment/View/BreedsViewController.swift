//
//  BreedsViewController.swift
//
//  Created by Hai Le Thanh.
//  Copyright © 2020 Hai Le Thanh. All rights reserved.
//
	

import UIKit

class BreedsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    private var viewModels: [BreedTableViewCellModel] = []
    var presenter: BreedsViewToPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        refreshData()
    }
    
    // MARK: - Private
    private func setupViews() {
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(BreedTableViewCell.self)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        loadingView.layer.cornerRadius = 8
        hideLoading()
    }
    
    @objc private func refreshData() {
        showLoading()
        presenter?.fetchData()
    }
    
    @IBAction func sortOrderChanged(_ sender: UISegmentedControl) {
        presenter?.applySort(sender.selectedSegmentIndex == 0 ? .ascending : .descending)
    }
}

extension BreedsViewController {
    private func showLoading() {
        loadingView.isHidden = false
        loadingIndicator.startAnimating()
    }
    
    private func hideLoading() {
        loadingView.isHidden = true
        loadingIndicator.stopAnimating()
    }
}

extension BreedsViewController: BreedsPresenterToViewProtocol {
    func displayData(_ viewModels: [BreedTableViewCellModel]) {
        hideLoading()
        self.viewModels.removeAll()
        self.viewModels.append(contentsOf: viewModels)
        
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
    }
    
    func displayError(message: String) {
        hideLoading()
        tableView.refreshControl?.endRefreshing()
        showAlert(title: "Error",
                  message: message,
                  primaryButtonTitle: "OK", primaryAction: { [weak self] in
                    self?.dismiss(animated: true, completion: nil)
        })
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

extension BreedsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.stopRequestDataForCell(at: indexPath.row)
    }
}
