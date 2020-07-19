//
//  ViewController.swift
//  Venturus
//
//  Created by Renan Benatti Dias on 17/07/20.
//  Copyright © 2020 Renan Benatti Dias. All rights reserved.
//

import UIKit
import Combine

enum Sections: Hashable {
    case cats
}

final class ViewController: UICollectionViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Sections, ImgurPage>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Sections, ImgurPage>
    
    private lazy var dataSource = makeDataSource()
    private var cancellables = Set<AnyCancellable>()
    private let cache = CatImageCache()
    private var imgurPages: [ImgurPage] = [] {
        didSet { applySnapshot() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(
            UINib(nibName: "ImgurlImageCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "ImgurlImageCollectionViewCell")
        makeRequest()
    }
}

// MARK: - Imgurl Request
private extension ViewController {
    func makeRequest() {
        cancellables = Set<AnyCancellable>()
        guard let imgurURL = URL(string: "https://api.imgur.com/3/gallery/search/?q=cats&q_type=jpg") else { return }
        var urlRequest = URLRequest(url: imgurURL)
        urlRequest.setValue("Client-ID 1ceddedc03a5d71", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTaskPublisher(for: urlRequest)
            .receive(on: DispatchQueue.global(qos: .background))
            .map(\.data)
            .decode(type: ImgurRequest.self, decoder: JSONDecoder())
            .map(\.imgurImages)
            .catch { _ in Just([ImgurPage]()) }
            .receive(on: RunLoop.main)
            .assign(to: \.imgurPages, on: self)
            .store(in: &cancellables)
    }
}

// MARK: - UICollectionViewDataSource
private extension ViewController {
    func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { (collectionView, indexPath, image) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImgurlImageCollectionViewCell", for: indexPath) as? ImgurlImageCollectionViewCell
            let viewModel = ImgurlImageCellViewModel(imgurPage: self.imgurPages[indexPath.row], cache: self.cache)
            cell?.setup(with: viewModel)
            return cell
        }
        return dataSource
    }
    
    func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([Sections.cats])
        let filteredImgurPages = imgurPages
            .filter { $0.images != nil }
            .filter { !($0.images?.isEmpty ?? false) }
        snapshot.appendItems(filteredImgurPages, toSection: Sections.cats)
        dataSource.apply(snapshot)
    }
}
