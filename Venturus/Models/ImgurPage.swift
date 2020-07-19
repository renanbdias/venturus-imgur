//
//  ImgurPage.swift
//  Venturus
//
//  Created by Renan Benatti Dias on 18/07/20.
//  Copyright © 2020 Renan Benatti Dias. All rights reserved.
//

import Foundation

struct ImgurPage: Hashable, Codable {
    let title: String
    let images: [ImgurImage]?
    
    enum CodingKeys: String, CodingKey {
        case title
        case images = "images"
    }
}
