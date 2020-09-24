//
//  BaseViewModel.swift
//
//  Created by Hai Le Thanh.
//  Copyright © 2020 Hai Le Thanh. All rights reserved.
//
	

import Foundation

protocol BaseViewModel { }

protocol ViewConfigurable {
    func configure(with viewModel: BaseViewModel)
}
