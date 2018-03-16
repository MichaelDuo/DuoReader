//
//  DuoReaderContainer.swift
//  DuoReader
//
//  Created by Yuxi Dong on 16/03/2018.
//  Copyright © 2018 MichaelDuo. All rights reserved.
//

import UIKit

class DPReaderContainer: UIViewController {
    
    var centerViewController:DPReaderCenter!
    var fileUrl:URL!
    var book:DPBook?
    var reader: DPReader!
    var config: DPReaderConfig!
    var type: String!
    
    var showStatusBar = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return !showStatusBar
    }
    
    public init(withConfig config: DPReaderConfig, dpReader: DPReader, epubURL: URL, type: String) {
        super.init(nibName: nil, bundle: Bundle.main)
        self.fileUrl = epubURL
        self.type = type
        self.reader = dpReader
        self.config = config
    }
    
    public func ready(completion: @escaping ()->Void){
        self.loadBook {
            DispatchQueue.main.async {
                let storyBoard = UIStoryboard.init(name: "Reader", bundle: nil)
                self.centerViewController = storyBoard.instantiateViewController(withIdentifier: "CenterViewController") as! DPReaderCenter
                self.centerViewController.readerContainer = self
                self.view.addSubview(self.centerViewController.view)
                self.addChildViewController(self.centerViewController)
                completion()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension DPReaderContainer {
    func loadBook(completion: @escaping ()->Void){
        print("Load Book")
        let ext = type!
        var bookGenerator:DPBookGenerator
        if ["epub", "txt"].contains(ext) {
            switch ext {
            case "epub":
                bookGenerator = Epub(fileUrl: fileUrl)
            case "txt":
                bookGenerator = Txt(fileUrl: fileUrl)
            default:
                print("Unknown File Type")
                bookGenerator = Txt(fileUrl: fileUrl)
            }
            bookGenerator.parse { (book) in
                self.book = book
                completion()
            }
        } else {
            print("\(ext) File")
            self.book = nil
            
            let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let bookDir = documentDir.appendingPathComponent("book", isDirectory: true)
            let dstUrl = bookDir.appendingPathComponent("\(fileUrl.lastPathComponent).\(ext)", isDirectory: false)
            
            do {
                print("Trying to copy from: \(fileUrl), to: \(dstUrl)")
                if !FileManager.default.fileExists(atPath: bookDir.path) {
                    try FileManager.default.createDirectory(at: bookDir, withIntermediateDirectories: true, attributes: nil)
                }
                
                if !FileManager.default.fileExists(atPath: dstUrl.path) {
                    try FileManager.default.copyItem(at: fileUrl, to: dstUrl)
                }
            } catch let error {
                print("Copy Error")
                print(error)
                return
            }
            
            fileUrl = dstUrl
            completion()
        }
    }
}
