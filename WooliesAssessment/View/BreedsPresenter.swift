//
//  BreedsPresenter.swift
//
//  Created by Hai Le Thanh.
//  Copyright © 2020 Hai Le Thanh. All rights reserved.
//
	

import Foundation
import UIKit

enum SortType {
    case ascending
    case descending
}

protocol BreedsPresenterToViewProtocol: class {
    func displayData(_ viewModels: [BreedTableViewCellModel])
    func displayError(message: String)
}

protocol BreedsViewToPresenterProtocol {
    func fetchData()
    func applySort(_ type: SortType)
    func requestDataForCellIfNeeded(at index: Int)
    func stopRequestDataForCell(at index: Int)
}

class BreedsPresenter {
    private weak var view: BreedsPresenterToViewProtocol?
    private let interactor: BreedsPresenterToInteractorProtocol
    
    var breeds: [Breed] = []
    var viewModels: [BreedTableViewCellModel] = []
    
    private let sortType = Observable<SortType>(.ascending)
    
    init(view: BreedsPresenterToViewProtocol,
         interactor: BreedsPresenterToInteractorProtocol) {
        self.view = view
        self.interactor = interactor
        
        sortType.valueChanged = { [weak self] value in
            self?.applySortAndUpdateViewModel()
        }
    }
    
    private func applySortAndUpdateViewModel() {
        breeds.sort { first, second -> Bool in
            var left = first
            var right = second
            guard let firstLifeSpan = left.minMaxLifeSpan, let secondLifeSpan = right.minMaxLifeSpan else { return false }
            if case .ascending = sortType.value {
                return firstLifeSpan.min < secondLifeSpan.min || (firstLifeSpan.min == secondLifeSpan.min && firstLifeSpan.max < secondLifeSpan.max)
            } else {
                return firstLifeSpan.min > secondLifeSpan.min || (firstLifeSpan.min == secondLifeSpan.min && firstLifeSpan.max > secondLifeSpan.max)
            }
        }
        
        viewModels = breeds.compactMap { breed in
            BreedTableViewCellModel(imageState: Observable<ImageState>(!breed.url.isEmpty ? .loading : .none),
                                    title: breed.name,
                                    description: breed.lifeSpan)
        }
        
        self.view?.displayData(self.viewModels)
    }
}

extension BreedsPresenter: BreedsViewToPresenterProtocol {
    func fetchData() {
        interactor.requestData()
    }
    
    func applySort(_ type: SortType) {
        sortType.value = type
    }
    
    func requestDataForCellIfNeeded(at index: Int) {
        guard index >= 0, index < breeds.count else { return }
        let rowItem = breeds[index]
        let viewModel = viewModels[index]        
        
        if viewModel.imageState.value == .fail {
            viewModel.imageState.value = .loading
        }
        
        if viewModel.imageState.value == .loading {
            interactor.requestImage(for: rowItem)
        }
    }
    
    func stopRequestDataForCell(at index: Int) {
        guard index >= 0, index < breeds.count else { return }
        let rowItem = breeds[index]
        clearDataForCell(at: index - 10)
        clearDataForCell(at: index + 10)
        interactor.cancelRequestImage(for: rowItem)
    }
    
    private func clearDataForCell(at index: Int) {
        guard index >= 0, index < viewModels.count else { return }
        
        let viewModel = viewModels[index]
        if case ImageState.loadedImage(_) = viewModel.imageState.value {
            viewModel.imageState.value = .loading
        }
    }
}

extension BreedsPresenter: BreedsInteractorToPresenterProtocol {
    func didFetchData(_ breeds: [Breed]) {
        self.breeds.removeAll()
        self.breeds.append(contentsOf: breeds)
        
        applySortAndUpdateViewModel()
    }
    
    func handleError(_ error: Error) {
        view?.displayError(message: error.localizedDescription)
    }
    
    func didFetchImage(for breed: Breed, image: UIImage) {
        guard let index = breeds.firstIndex(where: { breed.id == $0.id }) else { return }
        let viewModel = viewModels[index]
        viewModel.imageState.value = .loadedImage(image: image)
    }
    
    func didFailFetchImage(for breed: Breed, error: Error) {
        guard let index = breeds.firstIndex(where: { breed.id == $0.id }) else { return }
        let viewModel = viewModels[index]
        viewModel.imageState.value = .fail
    }
}

