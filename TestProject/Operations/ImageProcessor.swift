//
//  ImageProcessor.swift
//  TestProject
//
//  Created by Sai Kishore Swaminathan on 17/04/22.
//

import Foundation
import UIKit

class ImageProcessor: Operation {
    var urlCell: URLCell


    init(urlCell: URLCell) {
        self.urlCell = urlCell
    }

    override func main() {
        // Start Processing here
        guard urlCell.state != .failed else {
            return 
        }
        someHeavyProcessing()

        urlCell.image = urlCell.image?.getThumbnail()
        urlCell.state = .finished
    }

    private func someHeavyProcessing() {
        var counter = 0
        for _ in 0...Int.random(in: 99999...10000000) {
            counter += 1
        }
    }
}
