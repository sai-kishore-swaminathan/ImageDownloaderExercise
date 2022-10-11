//
//  Utils.swift
//  TestProject
//
//  Created by Sai Kishore Swaminathan on 04/04/22.
//

import Foundation
import UIKit

extension UIColor {
    static var colorOne: UIColor = UIColor(red: 224/255, green: 187/255, blue: 228/255, alpha: 1)
    static var colorTwo: UIColor = UIColor(cgColor: CGColor(red: 149/255, green: 125/255, blue: 173/255, alpha: 1))
}

enum QueueQos: String {
   case background = "background"
   case utility = "Utility"
}
