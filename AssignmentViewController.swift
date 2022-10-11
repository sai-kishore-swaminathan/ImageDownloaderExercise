//
//  AssignmentViewController.swift
//  TestProject
//
//  Created by Sai Kishore Swaminathan on 16/04/22.
//

import Foundation

import UIKit

final class AssinmentViewController: UIViewController,
                               UITableViewDataSource,
                               UITableViewDelegate {
    // MARK: - Variable
    @IBOutlet weak var myTableView: UITableView!
    var myUrlCells: [URLCell] = [URLCell]()
    @IBOutlet weak var startDownloadButton: UIButton!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.delegate = self
        myTableView.dataSource = self
    }

    // MARK: - Loading Data
    @IBAction func startDownload(_ sender: Any) {
        self.myUrlCells = ImageUrls.getUrlCells()
        self.downloadCellsAndUpdateText(urlCells: myUrlCells) { [unowned self] in
            startDownloadButton.titleLabel?.text = "Download Again"
        }
    }

    private func reloadDataAsynchronously() {
        DispatchQueue.main.async {
            print("Updating UI \(Thread.current)")
            self.myTableView.reloadData()
        }
    }

    func downloadCellsAndUpdateText(urlCells: [URLCell], completion: @escaping (() -> Void)) {
        for i in 0...urlCells.count-1 {
            let urlCell = urlCells[i]
            urlCell.state = .downloading
            print("Downloading urlCell \(i) \(Thread.current) ")
            reloadDataAsynchronously()
            URLSession.shared.dataTask(with: urlCell.url!) { [unowned self] data, response, error in
                guard let data = data,
                      let image = UIImage(data: data),
                      error == nil else {
                          return
                      }
                print("Processing urlCell \(i) \(Thread.current)")
                urlCell.state = .processing
                self.reloadDataAsynchronously()
                urlCell.image = image.getThumbnail()
                heavyProcessingCalculations()
                print("Finished urlCell \(i) \(Thread.current) ")
                urlCell.state = .finished
                self.reloadDataAsynchronously()
            }.resume()
        }
        completion()
    }

    private func heavyProcessingCalculations() {
        var counter = 0
        for _ in 0...Int.random(in: 99999...10000000) {
            counter += 1
        }
    }

    // MARK: - Table View delegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myUrlCells.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mycell", for: indexPath) as! MyTableViewCell
        let urlCells = myUrlCells[indexPath.row]
        cell.titleLabel.text = urlCells.state?.rawValue
        cell.thumbnailImageView.image =  urlCells.image
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
}





//    func downloadCellsAndUpdateText(urlCells: [URLCell], completion: @escaping (() -> Void)) {
//        DispatchQueue.global().async { [weak self] in
//
//            for i in 0...urlCells.count-1 {
//                let urlCell = urlCells[i]
//                urlCell.state = .downloading
//                print("Downloading urlCell \(i) \(Thread.current) ")
//                self?.reloadDataAsynchronously()
//                URLSession.shared.dataTask(with: urlCell.url!) { [unowned self] data, response, error in
//                    guard let data = data,
//                          let image = UIImage(data: data),
//                          error == nil else {
//                              return
//                          }
//                    print("Processing urlCell \(i) \(Thread.current)")
//                    urlCell.state = .processing
//                    self.reloadDataAsynchronously()
//                    urlCell.image = image.getThumbnail()
//                    heavyProcessingCalculations()
//                    print("Finished urlCell \(i) \(Thread.current) ")
//                    urlCell.state = .finished
//                    self?.reloadDataAsynchronously()
//                }.resume()
//            }
//
//            completion()
//        }
//    }
