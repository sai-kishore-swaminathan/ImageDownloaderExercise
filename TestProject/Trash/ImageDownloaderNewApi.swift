//
//  ImageDownloaderNewApi.swift
//  TestProject
//
//  Created by Sai Kishore Swaminathan on 13/09/22.
//

import Foundation
import UIKit


//final class ImageDownloaderNewApi {
//    let pendingOperations = PendingOperations()
//    var output: ImageDownloaderOutput? = nil
//
//     func startDownloadingImage(urlCell: URLCell, indexPath: IndexPath) {
//        guard pendingOperations.downloadsInProgress[indexPath] == nil else {
//            return
//        }
//
//        urlCell.state = .downloading
//        self.myTableView.reloadRows(at: [indexPath], with: .fade)
//
//        // Download Image here
//        let downloader = ImageDownloader(urlCell: urlCell)
//
//        downloader.completionBlock = {
//            // Check Cancellation
//            DispatchQueue.main.async {
//                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
//                self.myTableView.reloadRows(at: [indexPath], with: .fade)
//            }
//            print("Downloaded \(indexPath.row)")
//        }
//
//        pendingOperations.downloadsInProgress[indexPath] = downloader
//
//        pendingOperations.downloadQueue.addOperation(downloader)
//    }
//
//     func startProcessing(urlCell: URLCell, indexPath: IndexPath) {
//        guard pendingOperations.processingInProgress[indexPath] == nil else {
//            return
//        }
//
//        urlCell.state = .processing
//        self.myTableView.reloadRows(at: [indexPath], with: .fade)
//
//        // Download Image here
//        let processor = ImageProcessor(urlCell: urlCell)
//
//        processor.completionBlock = {
//            // Check Cancellation
//            DispatchQueue.main.async {
//                self.pendingOperations.processingInProgress.removeValue(forKey: indexPath)
//                self.myTableView.reloadRows(at: [indexPath], with: .fade)
//            }
//            print("Processed \(indexPath.row)")
//
//        }
//
//        pendingOperations.processingInProgress[indexPath] = processor
//
//        pendingOperations.processingQueue.addOperation(processor)
//    }
//}
