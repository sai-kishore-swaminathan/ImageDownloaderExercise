//
//  DummyViewController.swift
//  TestProject
//
//  Created by Sai Kishore Swaminathan on 16/04/22.
//

import Foundation
import UIKit

final class GcdViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ImageDownloaderOutput {

    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var startDownloadButton: UIButton!

    var imageDownloader = ImageDownloaders()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.delegate = self
        myTableView.dataSource = self
        imageDownloader.output = self
    }

    // MARK: - Action Methods
    @IBAction func startDownload(_ sender: Any) {
        self.imageDownloader.downloadGCD(urlCells: ImageUrls.getUrlCells()) { [weak self] in

            DispatchQueue.main.async {
                self?.startDownloadButton.setTitle("Download Again", for: .normal)
                let image = UIImage(systemName: "checkmark.seal.fill")
                self?.startDownloadButton.setImage(image, for: .normal)
            }
        }
    }

    // MARK: - Table View delegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageDownloader.getCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mycell", for: indexPath) as! MyTableViewCell
        let urlCells = imageDownloader.getCell(uid: indexPath.row)
        cell.setTitle(urlState: urlCells?.state)
        cell.thumbnailImageView.image = urlCells?.image
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
