//
//  ImgurlImageCollectionViewCell.swift
//  Venturus
//
//  Created by Renan Benatti Dias on 17/07/20.
//  Copyright © 2020 Renan Benatti Dias. All rights reserved.
//

import UIKit
import Combine

protocol ImgurlImageCollectionViewCellInterface {
    var title: String { get }
    var imagePublisher: AnyPublisher<UIImage?, Never> { get }
    func loadImage()
}

final class ImgurlImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var cancellable: AnyCancellable?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.startAnimating()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellable?.cancel()
        backgroundImageView.image = nil
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func setup(with viewModel: ImgurlImageCollectionViewCellInterface) {
        titleLabel.text = viewModel.title
        cancellable = viewModel.imagePublisher
            .receive(on: RunLoop.main)
            .handleEvents(receiveOutput: { [weak self] (img) in
                if img != nil {
                    self?.activityIndicator.stopAnimating()
                    self?.activityIndicator.isHidden = true
                }
            })
            .assign(to: \.image, on: backgroundImageView)

        viewModel.loadImage()
    }
}
