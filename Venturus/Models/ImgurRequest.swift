//
//  ImgurRequest.swift
//  Venturus
//
//  Created by Renan Benatti Dias on 18/07/20.
//  Copyright © 2020 Renan Benatti Dias. All rights reserved.
//

import Foundation

struct ImgurRequest: Codable {
    let imgurImages: [ImgurPage]
    
    enum CodingKeys: String, CodingKey {
        case imgurImages = "data"
    }
}
