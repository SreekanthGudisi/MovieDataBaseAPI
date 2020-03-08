//
//  StorageImageViewController.swift
//  DayToDay
//
//  Created by Matrix 1 MBP on 04/03/20.
//  Copyright © 2020 Matrix 1 MBP. All rights reserved.
//

import UIKit

class StorageImageViewController {

    // Class StroreImages
    static func storeImage(urlstring: String, img: UIImage) {
        
        let path = NSTemporaryDirectory().appending(UUID().uuidString)
        let url = URL(fileURLWithPath: path)
        let data = img.jpegData(compressionQuality: 0.7)
        try? data?.write(to: url)
        var dict = UserDefaults.standard.object(forKey: "ImageCache") as? [String : String]
        if dict == nil {
            dict = [ String: String]()
        }
        dict![urlstring] = path
        UserDefaults.standard.set(dict, forKey: "ImageCache")
    }
}
