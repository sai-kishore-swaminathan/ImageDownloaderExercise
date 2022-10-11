//
//  ImageDownloader03.swift
//  TestProject
//
//  Created by Sai Kishore Swaminathan on 18/04/22.
//

import Foundation
import UIKit

actor ImageDownloader03 {

    // We added this last time but not sure how to work this out
    private enum cacheEntry {
        case inProgress(Task<UIImage,Error>)
        case ready(UIImage)
    }
    private var cache: [URL: cacheEntry] = [:]
}
