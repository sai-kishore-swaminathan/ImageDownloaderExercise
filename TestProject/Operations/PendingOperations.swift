//
//  PendingOperations.swift
//  TestProject
//
//  Created by Sai Kishore Swaminathan on 18/04/22.
//

import Foundation

class PendingOperations {
    lazy var downloadsInProgress = [Int : Operation]()
    lazy var processingInProgress = [Int : Operation]()

    lazy var downloadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "downloadQueue"
        queue.maxConcurrentOperationCount = 3
        return queue
    }()

    lazy var processingQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "processingQueue"
        queue.maxConcurrentOperationCount = 3
        return queue
    }()
}
