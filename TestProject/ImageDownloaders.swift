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

    public init() {}
    
    var output: ImageDownloaderOutput? = nil
    let pendingOperations = PendingOperations()
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
        operationsObserver = pendingOperations.processingQueue.observe(\.operationCount,
                                                                        options: [.new]) { [unowned self] (queue, change) in
            if change.newValue! == 0 {
                operationsObserver = nil
                completion()
            }
        }

        for i in 0...urlCells.count-1 {
            let urlCell = urlCells[i]

            if urlCellCache.getElement(uid: urlCell.uid) != nil {
                continue
            }

            urlCellCache.addElement(uid: urlCell.uid, urlCell: urlCell)
            guard pendingOperations.downloadsInProgress[urlCell.uid] == nil else {
                return
            }

            urlCellCache.updateState(uid: urlCell.uid, state: .downloading)
            output?.reloadDataAsynchronously()

            // Downloading - NonOptional for simplicity
            let downloadingOperation = ImageDownloaderOperationSubClass(urlCell: urlCellCache.getElement(uid: urlCell.uid)!)
            downloadingOperation.completionBlock = {
                    // Check Cancellation
                    DispatchQueue.main.async { [weak self] in
                        self?.pendingOperations.downloadsInProgress.removeValue(forKey: urlCell.uid)
                        self?.output?.reloadDataAsynchronously()
                        self?.urlCellCache.addElement(uid: urlCell.uid, urlCell: downloadingOperation.urlCell)

                        // Processing
                        self?.startProcessingImagesFromOperaton(urlCell: self?.urlCellCache.getElement(uid: urlCell.uid))

                    }
                    print("Downloaded \(urlCell.uid)")
                }
            pendingOperations.downloadsInProgress[urlCell.uid] = downloadingOperation
            pendingOperations.downloadQueue.addOperation(downloadingOperation)

        }
    }

    private func startProcessingImagesFromOperaton(urlCell: URLCell?) {

        guard let urlCell = urlCell else {
            return
        }

        guard pendingOperations.processingInProgress[urlCell.uid] == nil,
              urlCell.state != .failed else {
            return
        }

        urlCellCache.updateState(uid: urlCell.uid, state: .processing)
        output?.reloadDataAsynchronously()

        // Download Image here
        let processingOperation = ImageProcessor(urlCell: urlCell)

        processingOperation.completionBlock = {
            // Check Cancellation
            DispatchQueue.main.async {
                self.pendingOperations.processingInProgress.removeValue(forKey: urlCell.uid)
                self.urlCellCache.addElement(uid: urlCell.uid, urlCell: processingOperation.urlCell)
                self.output?.reloadDataAsynchronously()
            }
            print("Processed \(urlCell.uid)")
        }

        pendingOperations.processingInProgress[urlCell.uid] = processingOperation
        pendingOperations.processingQueue.addOperation(processingOperation)
    }

    // MARK: - Async Await

    func downloadUsingAsyncAwait(urlCells:[URLCell], completion:@escaping(()->Void)) {
        urlCellCache.clearCache()
        Task {
            for cell in urlCells {
                urlCellCache.addElement(uid: cell.uid, urlCell: cell)
                urlCellCache.updateState(uid: cell.uid, state: .downloading)
                self.output?.reloadDataAsynchronously()
                let image = try? await downloadImageAsyncAwait(from: cell.url)
                if let image = image {
                    urlCellCache.updateImage(uid: cell.uid, image: image)
                    urlCellCache.updateState(uid: cell.uid, state: .downloaded)
                    self.output?.reloadDataAsynchronously()

                    // Processing
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
            }
            completion()
        }
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
