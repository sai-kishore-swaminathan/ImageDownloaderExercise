//
//  ImageDownloader.swift
//  TestProject
//
//  Created by Sai Kishore Swaminathan on 17/04/22.
//

import Foundation
import UIKit

class ImageDownloaderOperationSubClass: Operation {
    var urlCell: URLCell

    init(urlCell: URLCell) {
        self.urlCell = urlCell
    }

    override func main() {

        if let image = try? Data(contentsOf: urlCell.url) {
            urlCell.state = .downloaded
            urlCell.image = UIImage(data: image)
        } else {
            urlCell.image = UIImage(named: "default_image_failed")
            urlCell.state = .failed
        }
    }
}
