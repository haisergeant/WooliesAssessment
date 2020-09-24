//
//  BreedTableViewCell.swift
//
//  Created by Hai Le Thanh.
//  Copyright © 2020 Hai Le Thanh. All rights reserved.
//
	

import UIKit

// MARK: - ImageState
enum ImageState: Equatable {
    case none
    case loading
    case fail
    case loadedImage(image: UIImage)
}

class BreedTableViewCellModel: BaseViewModel {
    let imageState: Observable<ImageState>
    let title: String
    let description: String
    
    init(imageState: Observable<ImageState>, title: String, description: String) {
        self.imageState = imageState
        self.title = title
        self.description = description
    }
}

class BreedTableViewCell: UITableViewCell, Reuseable, ViewConfigurable {
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private weak var viewModel: BreedTableViewCellModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.stopAnimating()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel?.imageState.valueChanged = nil
        viewModel = nil
    }
    
    func configure(with viewModel: BaseViewModel) {
        guard let viewModel = viewModel as? BreedTableViewCellModel else { return }
        self.viewModel = viewModel
        
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
        
        configureImage(with: viewModel.imageState.value)
        viewModel.imageState.valueChanged = { [weak self] state in
            self?.configureImage(with: state)
        }
    }
}

extension BreedTableViewCell {
    private func configureImage(with state: ImageState) {
        switch state {
        case .none:
            loadingIndicator.stopAnimating()
            avatarImageView.image = nil
        case .loading:
            loadingIndicator.startAnimating()
            avatarImageView.image = nil
        case .fail:
            loadingIndicator.stopAnimating()
            avatarImageView.image = nil
        case .loadedImage(let image):
            loadingIndicator.stopAnimating()
            avatarImageView.image = image
        }
    }
}
