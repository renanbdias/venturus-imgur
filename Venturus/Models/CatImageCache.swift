//
//  CatImageCache.swift
//  Venturus
//
//  Created by Renan Benatti Dias on 18/07/20.
//  Copyright © 2020 Renan Benatti Dias. All rights reserved.
//

import UIKit
import Foundation

protocol ImageCache {
    subscript(_ url: NSURL) -> UIImage? { get set }
}

final class CatImageCache: ImageCache {
    private let cache = NSCache<NSURL, UIImage>()
    
    subscript(_ key: NSURL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        set {
            if let newValue = newValue {
                cache.setObject(newValue, forKey: key)
            } else {
                cache.removeObject(forKey: key)
            }
        }
    }
}
