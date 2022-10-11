//
//  Legacy.swift
//  TestProject
//
//  Created by Sai Kishore Swaminathan on 11/09/22.
//

import Foundation

final class ViewControllerAPIs {
//    // Drawback - Completion gets called the moment we start downloading
//    func downloadCellsAndDoNothing(urlCells: [URLCellOld], completion: @escaping (() -> Void)) {
//        for i in 0...urlCells.count-1 {
//            let urlCell = urlCells[i]
//
//            // Downloading Section
//            urlCell.state = .downloading
//            print("Downloading urlCell \(i) \(Thread.current) ")
//            reloadDataAsynchronously()
//            URLSession.shared.dataTask(with: urlCell.url!) { [unowned self] data, response, error in
//                guard let data = data,
//                      let image = UIImage(data: data),
//                      error == nil else {
//                          return
//                      }
//
//                // Processing Section
//                print("Processing urlCell \(i) \(Thread.current)")
//                urlCell.state = .processing
//                self.reloadDataAsynchronously()
//                urlCell.image = image.getThumbnail()
//                heavyProcessingCalculations()
//
//                // Finished Section
//                print("Finished urlCell \(i) \(Thread.current) ")
//                urlCell.state = .finished
//                self.reloadDataAsynchronously()
//            }.resume()
//        }
//
//        // This gets called even before URL Session starts its work
//        completion()
//    }
//
//    // Works well, But we're using DataTask and have no control over the thread it performs in
//    func downloadCellsAndUpdateText(urlCells: [URLCellOld], completion: @escaping (() -> Void)) {
//        DispatchQueue.global().async { [weak self] in
//            let dispatchGroup = DispatchGroup()
//            for i in 0...urlCells.count-1 {
//                let urlCell = urlCells[i]
//
//                // Downloading Section
//                urlCell.state = .downloading
//                print("Downloading urlCell \(i) \(Thread.current) ")
//                self?.reloadDataAsynchronously()
//                dispatchGroup.enter()
//                URLSession.shared.dataTask(with: urlCell.url!) { [weak self] data, response, error in
//                    guard let data = data,
//                          let image = UIImage(data: data),
//                          error == nil else {
//                              urlCell.state = .failed
//                              self?.reloadDataAsynchronously()
//                              dispatchGroup.leave()
//                              return
//                          }
//
//                    // Processing Section
//                    urlCell.state = .processing
//                    self?.reloadDataAsynchronously()
//                    urlCell.image = image.getThumbnail()
//                    self?.heavyProcessingCalculations()
//
//                    // Finished SEction
//                    urlCell.state = .finished
//                    self?.reloadDataAsynchronously()
//                    dispatchGroup.leave()
//                }.resume()
//            }
//            dispatchGroup.wait()
//            completion()
//        }
//    }
//
//    // Using Data Api - More control over the threads
//    func downloadCellsAndUpdateTextUsingDataApi(urlCells: [URLCellOld], completion: @escaping (() -> Void)) {
//        DispatchQueue.global().async { [weak self] in
//            let dispatchGroup = DispatchGroup()
//            for i in 0...urlCells.count-1 {
//                let urlCell = urlCells[i]
//
//                // Downloading Section
//                urlCell.state = .downloading
//                self?.reloadDataAsynchronously()
//                dispatchGroup.enter()
//                if let imageData = try? Data(contentsOf: urlCell.url!) {
//                    let image = UIImage(data: imageData)
//
//                    // Processing Section
//                    urlCell.state = .processing
//                    self?.reloadDataAsynchronously()
//                    urlCell.image = image!.getThumbnail()
//                    self?.heavyProcessingCalculations()
//
//                    // Finished section
//                    urlCell.state = .finished
//                    self?.reloadDataAsynchronously()
//                } else {
//                    urlCell.state = .failed
//                    urlCell.image = UIImage(named: "default_image_failed")
//                }
//                dispatchGroup.leave()
//            }
//            dispatchGroup.wait()
//            completion()
//        }
//    }
//
//    // Faster , still no control over processing. Processing and Downloading are in the same queue
//    func downloadCellsAndUpdateTextUsingSempahores(urlCells: [URLCellOld], completion: @escaping (() -> Void)) {
//        DispatchQueue.global().async { [weak self] in
//            let dispatchGroup = DispatchGroup()
//            print("Entered Global Queue \(Thread.current)")
//            for i in 0...urlCells.count-1 {
//                dispatchGroup.enter()
//
//                // Download Section
//                self?.downloadQueue.async {
//                    let urlCell = urlCells[i]
//                    urlCell.state = .downloading
//                    print("Downloading urlCell \(i) \(Thread.current) ")
//                    self?.reloadDataAsynchronously()
//                    if let imageData = try? Data(contentsOf: urlCell.url!) {
//                        let image = UIImage(data: imageData)
//
//                        // Processing Section
//                        urlCell.state = .processing
//                        self?.reloadDataAsynchronously()
//                        // Drawback: - I think If something goes wrong we can't find where
//                        image?.prepareThumbnail(of: CGSize(width: 70, height: 70), completionHandler: { thumbnail in
//                            urlCell.image = thumbnail
//                        })
//                        self?.heavyProcessingCalculations()
//
//                        // Finished Section
//                        print("Finished urlCell \(i)")
//                        urlCell.state = .finished
//                        self?.reloadDataAsynchronously()
//                    } else {
//                        urlCell.state = .failed
//                        urlCell.image = UIImage(named: "default_image_failed")
//                    }
//                    dispatchGroup.leave()
//                }
//            }
//            dispatchGroup.wait() // Synchronous in the thread I think cuz it blocks
//
//            // Alternatively I can use notify which fires on last leave()
//            // Wait also has a timer
//            completion()
//        }
//    }

    // Faster , still no control over processing. Processing and Downloading are in the same queue
    func downloadCellsAndUpdateTextUsingSempahores(urlCells: [URLCell], completion: @escaping (() -> Void)) {
//        DispatchQueue.global().async { [weak self] in
//            let dispatchGroup = DispatchGroup()
//            print("Entered Global Queue \(Thread.current)")
//            for i in 0...urlCells.count-1 {
//                dispatchGroup.enter()
//                self?.urlCellCache[urlCells[i].url] = urlCells[i]
//
//                // Download Section
//                self?.downloadQueue.async {
//                    let urlCell = urlCells[i]
//                    urlCellCache[urlcell.url]?.state = .downloading
//
//                    print("Downloading urlCell \(i) \(Thread.current) ")
//                    self?.reloadDataAsynchronously()
//                    if let imageData = try? Data(contentsOf: urlCell.url!) {
//                        let image = UIImage(data: imageData)
//
//                        // Processing Section
//                        urlCell.state = .processing
//                        self?.reloadDataAsynchronously()
//                        // Drawback: - I think If something goes wrong we can't find where
//                        image?.prepareThumbnail(of: CGSize(width: 70, height: 70), completionHandler: { thumbnail in
//                            urlCell.image = thumbnail
//                        })
//                        self?.heavyProcessingCalculations()
//
//                        // Finished Section
//                        print("Finished urlCell \(i)")
//                        urlCell.state = .finished
//                        self?.reloadDataAsynchronously()
//                    } else {
//                        urlCell.state = .failed
//                        urlCell.image = UIImage(named: "default_image_failed")
//                    }
//                    dispatchGroup.leave()
//                }
//            }
//            dispatchGroup.wait() // Synchronous in the thread I think cuz it blocks
            // Alternatively I can use notify which fires on last leave()
            // Wait also has a timer
//            completion()
//        }
    }
}
