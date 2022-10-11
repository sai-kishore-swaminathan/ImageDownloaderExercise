//
//  ImageUrls.swift
//  TestProject
//
//  Created by Sai Kishore Swaminathan on 16/04/22.
//

import Foundation
import UIKit

struct URLCell {
    var url: URL
    var state: UrlState
    var image: UIImage? = UIImage(named: "default_image")!.getThumbnail()
    var uid: Int = -1
}


enum UrlState: String {
    case notDownloading
    case downloading
    case downloaded
    case processing
    case finished
    case failed
}


final class ImageUrls {
    internal static func getUrlCells() -> [URLCell] {
            var urlCells = [URLCell]()
            for i in 0...9 {
                var urlCell = URLCell(url: URL(string: "https://dummyimage.com/200/300")!, state: .notDownloading, uid: i)

                if i == 8 {
                    urlCell.url = URL(string: "https://algklknkasg/asgaskas/asg")!
                }

                urlCell.uid = i
                urlCells.append(urlCell)
            }
            return urlCells
    }

    internal static func getUrlCellsOld() -> [URLCellOld] {
        var urlCells = [URLCellOld]()
        for i in 0...9 {
            let urlCell = URLCellOld()
            urlCell.url = URL(string: "https://dummyimage.com/200/300")!
            if i == 8 {
                urlCell.url = URL(string: "https://algklknkasg/asgaskas/asg")
            }
            urlCell.uid = i
            urlCells.append(urlCell)
        }
        return urlCells
    }
}



// MARK: -

//let url: URL = URL(string: "https://cdn.arstechnica.net/wp-content/uploads/2018/06/macOS-Mojave-Dynamic-Wallpaper-transition.jpg")!
//let urlTew = URL(string: "https://cdn.cocoacasts.com/cc00ceb0c6bff0d536f25454d50223875d5c79f1/above-the-clouds.jpg")!
//
//let urlTwe = URL(string: "https://cdn.maikoapp.com/3d4b/4qhf5/180h.png")!
//
//let urlTwo: URL = URL(string: "http://i.imgur.com/w5rkSIj.jpg")!
//
//let urlThree: URL = URL(string: "//https://upload.wikimedia.org/wikipedia/commons/0/07/Huge_ball_at_Vilnius_center.jpg")!
//
