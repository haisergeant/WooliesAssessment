//
//  BreedsRouter.swift
//
//  Created by Hai Le Thanh.
//  Copyright © 2020 Hai Le Thanh. All rights reserved.
//
	

import UIKit

class BreedsRouter {
    class func breedsViewController() -> UIViewController {
        let controller: BreedsViewController = UIStoryboard(storyboard: .main).instantiateViewController()
        
        let interactor = BreedsInteractor(service: BreedService())
        let presenter = BreedsPresenter(view: controller,
                                        interactor: interactor)
        interactor.presenter = presenter
        controller.presenter = presenter
        return controller
    }
}
