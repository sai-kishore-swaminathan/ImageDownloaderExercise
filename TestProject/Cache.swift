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
    private let dispatchQueueCell = DispatchQueue(label: "com.cache.urlCell", attributes: .concurrent)


    func getElement(uid: Int) -> URLCell? {
        var urlCell: URLCell?
        dispatchQueueCell.sync {
            urlCell = urlCellCache[uid]
        }
        return urlCell
    }

    func addElement(uid: Int, urlCell: URLCell) {
        dispatchQueueCell.async(flags: .barrier) {
            self.urlCellCache[uid] = urlCell
        }
    }

    func updateState(uid: Int, state: UrlState) {
        dispatchQueueCell.async(flags: .barrier) {
            self.urlCellCache[uid]?.state = state
        }
    }

    func getState(uid:Int) ->  UrlState {
        guard let urlCell = getElement(uid: uid) else {
            return .failed
        }
        return urlCell.state
    }

    func updateImage(uid: Int, image: UIImage?) {
        dispatchQueueCell.async(flags: .barrier) { [weak self] in
            self?.urlCellCache[uid]?.image = image
        }
    }

    func getCount() -> Int {
        var count = 0
        dispatchQueueCell.sync {
            count = urlCellCache.count
        }
        return count
    }

    func clearCache() {
        dispatchQueueCell.sync {
            self.urlCellCache.removeAll()
        }
    }
}
