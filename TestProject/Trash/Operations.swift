//
//  Operations.swift
//  TestProject
//
//  Created by Sai Kishore Swaminathan on 13/09/22.
//

import Foundation


//class OperationsViewController: UIViewController, UITableViewDataSource,
//                                UITableViewDelegate, ImageDownloaderOutput {
//
//    @IBOutlet weak var myTableView: UITableView!
//    @IBOutlet weak var startDownloadButton: UIButton!
//
//    let imageDownloader = ImageDownloaders()
//
//    // MARK: - LifeCycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.myTableView.dataSource = self
//        self.myTableView.delegate = self
//        self.imageDownloader.output = self
//
////        observation = pendingOperations.processingQueue.observe(\.operationCount,
////                                                                 options: [.new]) { [unowned self] (queue, change) in
////            if change.newValue! == 0 {
////                // Do something here when your queue has completed
////                DispatchQueue.main.async { [weak self] in
////                    self?.startDownloadButton.setTitle("Download Again", for: .normal)
////                    let image = UIImage(systemName: "checkmark.seal.fill")
////                    self?.startDownloadButton.setImage(image, for: .normal)
////                }
////                self.observation = nil
////            }
////        }
//
//    }
//
//    // MARK: - Actions
//    @IBAction func startDownloadButtonPressed(_ sender: Any) {
//        DispatchQueue.main.async { [weak self] in
//            self?.myTableView.reloadData()
//            self?.imageDownloader.downloadUsingOperations(urlCells: ImageUrls.getUrlCells(), completion: {
//                DispatchQueue.main.async { [weak self] in
//                    self?.startDownloadButton.setTitle("Download Again", for: .normal)
//                    let image = UIImage(systemName: "checkmark.seal.fill")
//                    self?.startDownloadButton.setImage(image, for: .normal)
//                }
//            })
//        }
//    }
//
//    //MARK: - TableView
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return imageDownloader.urlCellCache.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell01", for: indexPath) as! MyTableViewCell
//        let urlCell = myUrlCells[indexPath.row]
//
//        switch urlCell.state {
//        case nil:
//            startDownloadingImage(urlCell: urlCell, indexPath: indexPath)
//        case .downloaded:
//            startProcessing(urlCell: urlCell, indexPath: indexPath)
//        default:
//            break
//        }
//
//        cell.setTitle(urlState: urlCell.state)
//        cell.thumbnailImageView.image =  urlCell.image
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 180
//    }
//
//    // MARK: - Private Methods
//
//    private func startDownloadingImage(urlCell: URLCellOld, indexPath: IndexPath) {
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
//    private func startProcessing(urlCell: URLCellOld, indexPath: IndexPath) {
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
//
//    // MARK: - ImageDownloaderOutput
//
//    func reloadDataAsynchronously() {
//        myTableView.reloadData()
//    }
//}
//
//
///*
// - Abstract solutions ( Use Image Downloader )
// - Use same class with same function
// - Explore Cancellation Options
// - Use Collection Cells + Insert new cells ( Low priority )
// - How would you cancel one or more of the 100 images you just downloaded ( Low Priority)
// */
