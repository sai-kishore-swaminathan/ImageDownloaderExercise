//
//  OperationsViewController.swift
//  TestProject
//
//  Created by Sai Kishore Swaminathan on 17/04/22.
//

import UIKit

class OperationsViewController: UIViewController, UITableViewDataSource,
                                UITableViewDelegate, ImageDownloaderOutput {

    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var startDownloadButton: UIButton!

    let pendingOperations = PendingOperations()
    let imageDownloader: ImageDownloaders!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        imageDownloader = ImageDownloaders(pendingOperations: pendingOperations)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        imageDownloader = ImageDownloaders(pendingOperations: pendingOperations)
        super.init(coder: coder)
    }


    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        self.imageDownloader.output = self
    }

    // MARK: - Actions
    @IBAction func startDownloadButtonPressed(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            self?.myTableView.reloadData()
            self?.imageDownloader.downloadUsingOperations(urlCells: ImageUrls.getUrlCells(), completion: {
                DispatchQueue.main.async { [weak self] in
                    self?.startDownloadButton.setTitle("Download Again", for: .normal)
                    let image = UIImage(systemName: "checkmark.seal.fill")
                    self?.startDownloadButton.setImage(image, for: .normal)
                }
            })
        }
    }

    @IBAction func cancelAll(_ sender: Any) {
        pendingOperations.downloadQueue.cancelAllOperations()
        pendingOperations.processingQueue.cancelAllOperations()
    }

    //MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageDownloader.getCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell01", for: indexPath) as! MyTableViewCell
        let urlCells = imageDownloader.getCell(uid: indexPath.row)
        cell.setTitle(urlState: urlCells?.state)
        cell.thumbnailImageView.image =  urlCells?.image
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }

    // MARK: - ImageDownloaderOutput
    
    func reloadDataAsynchronously() {
        DispatchQueue.main.async {
            self.myTableView.reloadData()
        }
    }
}
