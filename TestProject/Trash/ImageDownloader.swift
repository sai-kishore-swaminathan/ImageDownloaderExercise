//
//  ImageDownloader.swift
//  TestProject
//
//  Created by Sai Kishore Swaminathan on 16/04/22.
//

import Foundation
import UIKit

class URLCellOld {
    var url: URL? = nil
    var state: UrlState? = nil
    var image: UIImage? = UIImage(named: "default_image")!.getThumbnail()
    var uid: Int = -1
}


//class MyObserver: NSObject {
//    @objc var objectToObserve: MyObjectToObserve
//    var observation: NSKeyValueObservation?
//
//    init(object: MyObjectToObserve) {
//        objectToObserve = object
//        super.init()
//
//        observation = observe(
//            \.objectToObserve.myDate,
//            options: [.old, .new]
//        ) { object, change in
//            print("myDate changed from: \(change.oldValue!), updated to: \(change.newValue!)")
//        }
//    }
//}

