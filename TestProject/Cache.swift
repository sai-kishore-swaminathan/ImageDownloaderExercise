//
//  Cache.swift
//  TestProject
//
//  Created by Sai Kishore Swaminathan on 11/10/22.
//

import Foundation
import UIKit

class URLCellCache {

    private var urlCellCache =  [Int:URLCell]()
    let addingElementMutex = NSRecursiveLock()
    let addingStateMutex = NSRecursiveLock()
    let updatingImageMutex = NSRecursiveLock()

    func getElement(uid: Int) -> URLCell? {
        return urlCellCache[uid]
    }

    func addElement(uid: Int, urlCell: URLCell) {
        urlCellCache[uid] = urlCell
    }

    func updateState(uid: Int, state: UrlState) {
        urlCellCache[uid]?.state = state
    }

    func getState(uid:Int) ->  UrlState {
        guard let urlCell = urlCellCache[uid] else {
            return .failed
        }
        return urlCell.state
    }

    func updateImage(uid: Int, image: UIImage?) {
        urlCellCache[uid]?.image = image
    }

    func getCount() -> Int {
        return urlCellCache.count
    }

    func clearCache() {
        urlCellCache.removeAll()
    }
}
