//
//  CacheWithSemaphores.swift
//  TestProject
//
//  Created by Sai Kishore Swaminathan on 11/10/22.
//

import Foundation
import UIKit

class URLCellCacheWithLocks {

    private var urlCellCache =  [Int:URLCell]()
    let cacheLock = NSRecursiveLock()

    func getElement(uid: Int) -> URLCell? {
        var cell: URLCell? = nil
        cacheLock.lock()
        cell = self.urlCellCache[uid]
        cacheLock.unlock()
        return cell
    }

    func getState(uid:Int) ->  UrlState {
        guard let urlCell = urlCellCache[uid] else {
            return .failed
        }
        return urlCell.state
    }

    func getCount() -> Int {
        var count: Int = 0
        cacheLock.lock()
        count = self.urlCellCache.count
        cacheLock.unlock()
        return count
    }

    // MARK: - Locks without Separate Dispatch Queue:
    func addElement(uid: Int, urlCell: URLCell) {
        self.cacheLock.lock()
        self.urlCellCache[uid] = urlCell
        self.cacheLock.unlock()
    }

    func updateState(uid: Int, state: UrlState) {
        self.cacheLock.lock()
        self.urlCellCache[uid]?.state = state
        self.cacheLock.unlock()
    }

    func updateImage(uid: Int, image: UIImage?) {
        self.cacheLock.lock()
        self.urlCellCache[uid]?.image = image
        self.cacheLock.unlock()
    }

    func clearCache() {
        self.cacheLock.lock()
        self.urlCellCache.removeAll()
        self.cacheLock.unlock()
    }

    // MARK: - Locks with Separate Dispatch Queue:

//    private let dispatchQueueCell = DispatchQueue(label: "com.cache.urlCell", attributes: .concurrent)

//    func addElement(uid: Int, urlCell: URLCell) {
//        dispatchQueueCell.async {
//            self.cacheLock.lock()
//            self.urlCellCache[uid] = urlCell
//            self.cacheLock.unlock()
//        }
//    }
//
//    func updateState(uid: Int, state: UrlState) {
//        dispatchQueueCell.async {
//            self.cacheLock.lock()
//            self.urlCellCache[uid]?.state = state
//            self.cacheLock.unlock()
//        }
//    }



//    func updateImage(uid: Int, image: UIImage?) {
//        dispatchQueueCell.async {
//            self.cacheLock.lock()
//            self.urlCellCache[uid]?.image = image
//            self.cacheLock.unlock()
//        }
//    }


//    func clearCache() {
//        dispatchQueueCell.async {
//            self.cacheLock.lock()
//            self.urlCellCache.removeAll()
//            self.cacheLock.unlock()
//        }
//    }

}

