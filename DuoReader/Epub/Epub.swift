//
//  Epub.swift
//  DuoReader
//
//  Created by Yuxi Dong on 16/03/2018.
//  Copyright © 2018 MichaelDuo. All rights reserved.
//

//
//  Epub.swift
//  Deerpark
//
//  Created by Yuxi Dong on 22/09/2017.
//  Copyright © 2017 XMind. All rights reserved.
//

import Zip

class Epub : DPBookGenerator {
    var fileUrl = URL(fileURLWithPath: "")
    var targetDir:URL
    
    private init(){
        let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let bookDir = documentDir.appendingPathComponent("book/\(fileUrl.lastPathComponent)", isDirectory: true)
        self.targetDir = bookDir
    }
    
    convenience required init(fileUrl: URL){
        self.init()
        self.fileUrl = fileUrl
    }
    
    func parse(completion: ((DPBook)->Void)?){
        unzipFile()
        let epubParser = EpubParser(dataSource: self)
        let epubBook = epubParser.parse()
        epubBook.loadChapterPercentage() //TODO: Refactor
        completion?(epubBook)
    }
    
    private func unzipFile(){
        do {
            print("unzip")
            print(fileUrl)
            print(targetDir)
            try Zip.unzipFile(fileUrl, destination: targetDir, overwrite: true, password: nil, progress: { (progress) in
            })
        }
            
        catch ZipError.fileNotFound {
            print(fileUrl)
            print("File Not Found")
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: fileUrl.path) {
                print("But Hey, File Is Actually Here")
                print(fileUrl.path)
                print(targetDir.path)
            } else {
                print("File Is Really Not Found")
            }
        }
            
        catch ZipError.unzipFail {
            print("Unzip Failed")
        } catch {
            print("Unzip failed...")
        }
    }
}

extension Epub: EpubParserDataSource {
    // Path passed into these function should be the relative path of the root folder!
    func getFileWith(path:String)->String? {
        return try? String(contentsOf: getFileUrl(path: path))
    }
    
    func getFileUrl(path:String)->URL {
        return URL(fileURLWithPath: path, relativeTo: targetDir)
    }
}
