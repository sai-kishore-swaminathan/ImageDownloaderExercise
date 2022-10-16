//
//  AysncViewController.swift
//  TestProject
//
//  Created by Sai Kishore Swaminathan on 18/04/22.
//

import UIKit

class AysncViewController: UIViewController, UITableViewDelegate,
                           UITableViewDataSource, ImageDownloaderOutput {

    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var startButton: UIButton!
    let imageDownloader = ImageDownloaders()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        self.imageDownloader.output = self
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        imageDownloader.downloadUsingAsyncAwait(urlCells: ImageUrls.getUrlCells()) {
            DispatchQueue.main.async {
                self.startButton.setTitle("Download Again", for: .normal)
                let image = UIImage(systemName: "checkmark.seal.fill")
                self.startButton.setImage(image, for: .normal)
            }
        }
    }

    //MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageDownloader.getCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell03", for: indexPath) as! MyTableViewCell
        let urlCell = imageDownloader.getCell(uid: indexPath.row)
        cell.setTitle(urlState: urlCell?.state)
        cell.thumbnailImageView.image =  urlCell?.image
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }

    // MARK: - ImageDownloaderOutput

    func reloadDataAsynchronously() {
        DispatchQueue.main.async{
            self.myTableView.reloadData()
        }
    }
}



// Ref https://gist.github.com/networkextension/654882c1283a7b0b6cb3117f91b8c948
//https://www.raywenderlich.com/5293-operation-and-operationqueue-tutorial-in-swift
//https://jayeshkawli.ghost.io/asynchronous-image-download-and-caching-in-swift/
//https://www.donnywals.com/using-swifts-async-await-to-build-an-image-loader/
//https://www.avanderlee.com/swift/async-await/
