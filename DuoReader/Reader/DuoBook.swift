//
//  DuoBook.swift
//  DuoReader
//
//  Created by Yuxi Dong on 16/03/2018.
//  Copyright © 2018 MichaelDuo. All rights reserved.
//

import Foundation
import UIKit

protocol DPBookGenerator {
    init(fileUrl: URL)
    func parse(completion: ((DPBook)->Void)?)
}

@objc protocol DPBook: class {
    var totalChapters: Int { get }
    var baseUrl: URL? { get }
    var chapterPercentages: [Double] { get }
    func getChapter(_ section: Int) -> String
    func getChapterTitle(_ chapterNumber: Int) -> String
    func getBaseUrl(_ chapterNumbner: Int) -> URL
    func getCover() -> UIImage
    
}

extension DPBook {
    func createHtmlWith(head: String?, body: String)->String{
        let cssFilePath = Bundle.main.path(forResource: "style", ofType: "css")
        let jsFilePath = Bundle.main.path(forResource: "ReaderJS/reader.bundle", ofType: "js")
        
        let cssTag = "<link rel=\"stylesheet\" type=\"text/css\" href=\"\(cssFilePath!)\">"
        let jsTag = "<script type=\"text/javascript\" src=\"\(jsFilePath!)\"></script>"
        
        return """
        <!DOCTYPE html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        \(head ?? "")
        \(cssTag)
        \(jsTag)
        </head>
        <body>
        <div>
        \(body)
        </div>
        <script>new Reader().mountWithId("app")</script>
        </body>
        </html>
        """
    }
    
    func getChapterNumAndChapterProgress(progress: Double) -> (Int, Double) {
        var chapterNumber = 0
        var chapterProgress = 0.0
        var searchedProgress = 0.0
        for (n, percentage) in chapterPercentages.enumerated() {
            if Double(progress) < searchedProgress + percentage {
                chapterNumber = n
                chapterProgress = (Double(progress) - searchedProgress) / percentage
                break
            }
            searchedProgress = searchedProgress + percentage
        }
        return (chapterNumber, chapterProgress)
    }
    
    func getProgress(chapterNumber: Int, chapterProgress: Double) -> Double {
        var progress = 0.0
        for i in 0..<chapterNumber {
            progress = progress + chapterPercentages[i]
        }
        progress = progress + chapterProgress * (chapterPercentages[chapterNumber])
        return progress
    }
}
