//
//  DuoReader.swift
//  DuoReader
//
//  Created by Yuxi Dong on 16/03/2018.
//  Copyright © 2018 MichaelDuo. All rights reserved.
//

import UIKit
import Zip

class DPReader: NSObject {
    static var supportedSufix = ["epub", "doc", "rtf", "txt", "html", "docx"]
    
    var readerContainer: DPReaderContainer!
    
    override init() {
        Zip.addCustomFileExtension("")
    }
    
    static func supports(suffix: String) -> Bool {
        return supportedSufix.contains(suffix)
    }
    
    func presentReader(parentViewController: UIViewController, forBook: DPBookMO, andConfig config: DPReaderConfig, animated: Bool = true) {
        
        let epubURL = forBook.assetAbsURL!
        let type    = forBook.type!
        
        readerContainer = DPReaderContainer(withConfig: config, dpReader: self, epubURL: epubURL, type: type)
        readerContainer.ready {
            parentViewController.present(self.readerContainer, animated: animated, completion: nil)
        }
    }
    
    func getCover(withFileURL epubURL: URL, ofType type: String, ofSize size: CGSize, completion: @escaping (UIImage?)->Void){
        if type != "epub" {
            return completion(nil)
        }
        readerContainer = DPReaderContainer(withConfig: DPReaderConfig(), dpReader: self, epubURL: epubURL, type: type)
        readerContainer.ready {
            guard let coverImage = self.readerContainer.book?.getCover() else {
                return completion(nil)
            }
            let widthToHeight = UIScreen.main.bounds.width / UIScreen.main.bounds.height
            var size = size
            size.height = size.width / widthToHeight
            size.width = size.width * UIScreen.main.scale
            size.height = size.height * UIScreen.main.scale
            UIGraphicsBeginImageContext(size)
            coverImage.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
            let resizedCover = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            completion(resizedCover)
        }
    }
}
