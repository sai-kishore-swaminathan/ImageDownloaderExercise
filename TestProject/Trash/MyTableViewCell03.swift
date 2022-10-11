//
//  MyTableViewCell03.swift
//  TestProject
//
//  Created by Sai Kishore Swaminathan on 18/04/22.
//

import UIKit

class MyTableViewCell03: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
