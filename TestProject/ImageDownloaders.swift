//
//  ImageDownloaders.swift
//  TestProject
//
//  Created by Sai Kishore Swaminathan on 11/08/22.
//

import Foundation
import UIKit

public protocol ImageDownloaderOutput {
    func reloadDataAsynchronously()
}

final class ImageDownloaders {

    let pendingOperations: PendingOperations?
    public init(pendingOperations: PendingOperations? = nil) {
        self.pendingOperations = pendingOperations
    }
    
    var output: ImageDownloaderOutput? = nil
    var operationsObserver: NSKeyValueObservation?
    // Replace the below cache with URLCellCache() for different implementation
    let urlCellCache = URLCellCacheWithLocks()
    let dummyImageProcessing = DummyTimeConsumingLogic()
    let downloadQueue = DispatchQueue(label: "com.testing.downloadqueue", attributes: .concurrent)

    // MARK: - GCD
    func downloadGCD(urlCells: [URLCell], completion: @escaping(()-> Void)) {

        DispatchQueue.global().async { [weak self] in
            let dispatchGroup = DispatchGroup()
            self?.urlCellCache.clearCache()
            print("Entered Global Queue \(Thread.current)")
            for i in 0...urlCells.count-1 {
                let urlCell = urlCells[i]
                dispatchGroup.enter()
                if self?.urlCellCache.getElement(uid: urlCell.uid) !=  nil {
                    dispatchGroup.leave()
                }
                else {
                    // Download Section
                    self?.downloadQueue.async {
                        self?.urlCellCache.addElement(uid: urlCell.uid, urlCell: urlCell)
                        self?.urlCellCache.updateState(uid: urlCell.uid, state: .downloading)
                        self?.output?.reloadDataAsynchronously()

                        print("Downloading urlCell \(i) \(Thread.current) ")
                        if let imageData = try? Data(contentsOf: urlCell.url) {
                            let image = UIImage(data: imageData)

                            // Processing Section
                            self?.urlCellCache.updateState(uid: urlCell.uid, state: .processing)
                            self?.output?.reloadDataAsynchronously()
                            image?.prepareThumbnail(of: CGSize(width: 70, height: 70), completionHandler: { thumbnail in
                                self?.urlCellCache.updateImage(uid: urlCell.uid, image: thumbnail)
                            })
                            self?.dummyImageProcessing.heavyProcessingCalculations()

                            // Finished Section
                            print("Finished urlCell \(i)")
                            self?.urlCellCache.updateState(uid: urlCell.uid, state: .finished)
                            self?.output?.reloadDataAsynchronously()
                        } else {
                            self?.urlCellCache.updateState(uid: urlCell.uid, state: .failed)
                            self?.urlCellCache.updateImage(uid: urlCell.uid, image: UIImage(named: "default_image_failed"))
                            self?.output?.reloadDataAsynchronously()
                        }
                        dispatchGroup.leave()
                    }
                }
            }
            dispatchGroup.wait()
            completion()
        }
    }

    // MARK: - Operations
    func downloadUsingOperations(urlCells:[URLCell], completion: @escaping(()->Void)) {
        urlCellCache.clearCache()

        guard let pendingOperations = pendingOperations else {
            /// Should pass Result with Error here but for simplicity keeping it like this 
            completion()
            return
        }

        /// Method 1: -  OperationCount is deprecated in iOS 13
        operationsObserver = pendingOperations.processingQueue.observe(\.operationCount,
                                                                        options: [.new]) { [unowned self] (queue, change) in
            if change.newValue! == 0 {
                operationsObserver = nil
                completion()
            }
        }

        /// Method 2: Completion using Operation Dependency
        var counter = 0
        let completionOperation = BlockOperation {
            print("Called here")
//            completion()
        }

        for i in 0...urlCells.count-1 {
            let urlCell = urlCells[i]

            if urlCellCache.getElement(uid: urlCell.uid) != nil {
                continue
            }

            /// Add Element to Cache
            urlCellCache.addElement(uid: urlCell.uid, urlCell: urlCell)

            /// Check if the this operation is already in queue
            guard pendingOperations.downloadsInProgress[urlCell.uid] == nil else {
                return
            }

            /// Update State
            urlCellCache.updateState(uid: urlCell.uid, state: .downloading)
            output?.reloadDataAsynchronously()

            ///  Start Downloading using Operation()
            let downloadingOperation = ImageDownloaderOperationSubClass(urlCell: urlCellCache.getElement(uid: urlCell.uid)!)
            pendingOperations.downloadsInProgress[urlCell.uid] = downloadingOperation
            pendingOperations.downloadQueue.addOperation(downloadingOperation)

            downloadingOperation.completionBlock = {
                // TODO: - Check Cancellation
                if downloadingOperation.isCancelled {
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    pendingOperations.downloadsInProgress.removeValue(forKey: urlCell.uid)
                    self?.output?.reloadDataAsynchronously()
                    self?.urlCellCache.addElement(uid: urlCell.uid, urlCell: downloadingOperation.urlCell)

                    ///  Start Processing
                    let processingOperation = self?.startProcessingImagesFromOperaton(urlCell: self?.urlCellCache.getElement(uid: urlCell.uid), pendingOperations: pendingOperations)
                    if let processingOperation {
                        completionOperation.addDependency(processingOperation)
                    }

                    counter += 1
                    if counter == urlCells.count - 1 {
                        /// Once all Processing Operations are added, add the dependent completion operation
                        pendingOperations.processingQueue.addOperation(completionOperation)

                        /// Method 3 - Can also use ( Just for experimentation purpose  Freezes the thread ( Synchronous )
                        //                            pendingOperations.processingQueue.waitUntilAllOperationsAreFinished()
                        print("Done")
                    }
                }
                print("Completed \(urlCell.uid)")
            }
        }
    }

    private func startProcessingImagesFromOperaton(urlCell: URLCell?,
                                                   pendingOperations: PendingOperations) -> Operation? {

        guard let urlCell = urlCell else {
            return nil
        }

        guard pendingOperations.processingInProgress[urlCell.uid] == nil,
              urlCell.state != .failed else {
            return nil
        }

        urlCellCache.updateState(uid: urlCell.uid, state: .processing)
        output?.reloadDataAsynchronously()

        /// Process Image here
        let processingOperation = ImageProcessor(urlCell: urlCell)

        processingOperation.completionBlock = {
            // Check Cancellation
            if processingOperation.isCancelled {
                return
            }

            DispatchQueue.main.async {
                pendingOperations.processingInProgress.removeValue(forKey: urlCell.uid)
                self.urlCellCache.addElement(uid: urlCell.uid, urlCell: processingOperation.urlCell)
                self.output?.reloadDataAsynchronously()
            }
            print("Processed \(urlCell.uid)")
        }

        pendingOperations.processingInProgress[urlCell.uid] = processingOperation
        pendingOperations.processingQueue.addOperation(processingOperation)
        return processingOperation
    }

    // MARK: - Async Await

    func downloadUsingAsyncAwait(urlCells:[URLCell], completion:@escaping(()->Void)) {
        urlCellCache.clearCache()
        Task {
            await withTaskGroup(of: URLCell?.self, body: { [self] group in
                for cell in urlCells {
                    group.addTask {
                        await self.fetchDownloadAndProcess(cell: cell)
                    }
                }
            })
            completion()
        }
    }

    func downloadUsingAsyncAwaitWithoutClosure(urlCells:[URLCell]) async -> Bool {
        urlCellCache.clearCache()
        await withTaskGroup(of: URLCell?.self, body: { [self] group in
            for cell in urlCells {
                group.addTask {
                    await self.fetchDownloadAndProcess(cell: cell)
                }
            }
        })
        return true
    }

    // MARK: - Async Await Helpers
    private func fetchDownloadAndProcess(cell: URLCell) async -> URLCell? {
        print("Cell \(cell.uid)")
        urlCellCache.addElement(uid: cell.uid, urlCell: cell)
        urlCellCache.updateState(uid: cell.uid, state: .downloading)
        self.output?.reloadDataAsynchronously()
        let image = try? await downloadImageAsyncAwait(from: cell.url)
        if let image = image {
            urlCellCache.updateImage(uid: cell.uid, image: image)
            urlCellCache.updateState(uid: cell.uid, state: .downloaded)
            
            // Processing
            urlCellCache.updateState(uid: cell.uid, state: .processing)
            self.output?.reloadDataAsynchronously()
            let processedImage = try? await processImage(for: image)
            if let processedImage = processedImage {
                urlCellCache.updateImage(uid: cell.uid, image: processedImage)
                urlCellCache.updateState(uid: cell.uid, state: .finished)
            }
            self.output?.reloadDataAsynchronously()
        } else {
            urlCellCache.updateState(uid: cell.uid, state: .failed)
        }
        self.output?.reloadDataAsynchronously()
        return urlCellCache.getElement(uid: cell.uid)
    }

    private func downloadImageAsyncAwait(from url: URL) async throws -> UIImage? {
        let imageTask = Task {
            try await downloadImageAndFetchThumbnail(for: url)
        }

        do {
            let image = try await imageTask.value
            return image
        } catch {
            throw error
        }
    }

    private func downloadImageAndFetchThumbnail(for url: URL) async throws -> UIImage {
        let urlRequest = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw DummyError.urlInvalid }
        let image = UIImage(data: data) ?? UIImage(named: "default")
        return image!
    }

    private func processImage(for image: UIImage) async throws -> UIImage {
        guard let thumbnail = await image.byPreparingThumbnail(ofSize: CGSize(width: 60, height: 60)) else { throw DummyError.thumbnailFailed }
        dummyImageProcessing.heavyProcessingCalculations()
        return thumbnail
    }

    //MARK: - ControllerInput
    
    func getCount() -> Int {
        return urlCellCache.getCount()
    }

    func getCell(uid: Int) -> URLCell? {
        return urlCellCache.getElement(uid: uid)
    }
}
