//
//  ImgurlImageCellViewModel.swift
//  Venturus
//
//  Created by Renan Benatti Dias on 17/07/20.
//  Copyright © 2020 Renan Benatti Dias. All rights reserved.
//

import UIKit
import Combine

final class ImgurlImageCellViewModel {
    let imgurPage: ImgurPage
    var cache: ImageCache
    
    @Published var image: UIImage?
    var cancellables = Set<AnyCancellable>()

    init(imgurPage: ImgurPage, cache: ImageCache) {
        self.imgurPage = imgurPage
        self.cache = cache
    }
    
    private func saveOnCache(image: UIImage?) {
        guard let firstImage = imgurPage.images?.first else { return }
        cache[firstImage.link as NSURL] = image
    }
}

// MARK: - ImgurlImageCollectionViewCellInterface
extension ImgurlImageCellViewModel: ImgurlImageCollectionViewCellInterface {
    var imagePublisher: AnyPublisher<UIImage?, Never> {
        $image.eraseToAnyPublisher()
    }
    
    var title: String {
        imgurPage.title
    }
    
    func loadImage() {
        guard let firstImage = imgurPage.images?.first else { return }
        if let cachedImage = cache[firstImage.link as NSURL] {
            image = cachedImage
        } else {
            URLSession.shared.dataTaskPublisher(for: firstImage.link)
                .receive(on: RunLoop.main)
                .map(\.data)
                .map(UIImage.init(data:))
                .catch { _ in Just(UIImage(systemName: "xmark.circle")) }
                .handleEvents(receiveOutput: saveOnCache(image:))
                .assign(to: \.image, on: self)
                .store(in: &cancellables)
        }
    }
}
