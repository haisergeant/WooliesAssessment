//
//  BreedsPresenter.swift
//
//  Created by Hai Le Thanh.
//  Copyright © 2020 Hai Le Thanh. All rights reserved.
//
	

import Foundation
import UIKit

protocol BreedsPresenterToViewProtocol: class {
    func displayData(_ viewModels: [BreedTableViewCellModel])
    func displayError(message: String)
}

protocol BreedsViewToPresenterProtocol {
    func fetchData()
    func requestDataForCellIfNeeded(at index: Int)
    func stopRequestDataForCell(at index: Int)
}

class BreedsPresenter {
    private weak var view: BreedsPresenterToViewProtocol?
    private let interactor: BreedsPresenterToInteractorProtocol
    
    var breeds: [Breed] = []
    var viewModels: [BreedTableViewCellModel] = []
    init(view: BreedsPresenterToViewProtocol, interactor: BreedsPresenterToInteractorProtocol) {
        self.view = view
        self.interactor = interactor
    }
}

extension BreedsPresenter: BreedsViewToPresenterProtocol {
    func fetchData() {
        interactor.requestData()
    }
    
    func requestDataForCellIfNeeded(at index: Int) {
        let viewModel = viewModels[index]
        let rowItem = breeds[index]
        
        if viewModel.imageState.value == .fail {
            viewModel.imageState.value = .loading
        }
        
        if viewModel.imageState.value == .loading {
            interactor.requestImage(for: rowItem)
        }
    }
    
    func stopRequestDataForCell(at index: Int) {
        let rowItem = breeds[index]
        interactor.cancelRequestImage(for: rowItem)
    }
    
    func clearDataForCell(at index: Int) {
        guard index >= 0, index < viewModels.count else {
            clearDataForCell(at: index - 10)
            clearDataForCell(at: index + 10)
            return            
        }
        
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
        
        viewModels = breeds.compactMap { breed in
            BreedTableViewCellModel(imageState: Observable<ImageState>(!breed.url.isEmpty ? .loading : .none),
                                    title: breed.name,
                                    description: breed.lifeSpan)
        }
        
        self.view?.displayData(self.viewModels)                
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

