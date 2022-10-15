//
//  MyTableViewCells.swift
//  TestProject
//
//  Created by Sai Kishore Swaminathan on 16/04/22.
//

import Foundation
import UIKit

class MyTableViewCell: UITableViewCell {

    let url: URL? = nil
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization codes
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    public func setTitle(urlState: UrlState?) {
        var color: UIColor!
        switch urlState {
        case .processing:
            color = .systemBlue
        case .finished:
            color = .systemGreen
        case .failed:
            color = .red
        default:
            color = .black
        }
        titleLabel.textColor = color
        titleLabel.text = urlState?.rawValue ?? ""
    }
}
