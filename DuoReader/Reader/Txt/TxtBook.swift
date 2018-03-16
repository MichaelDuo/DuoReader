//
//  TxtBook.swift
//  DeerPark
//
//  Created by Yuxi Dong on 25/10/2017.
//  Copyright © 2017 XMind Ltd. All rights reserved.
//

import UIKit

class TxtBook: DPBook {
    
    var chapterPercentages: [Double] = [1]
    
    var rawString = ""
    
    var totalChapters: Int {
        return 1
    }
    
    var baseUrl: URL?
    
    func getChapter(_ section: Int) -> String {
        return createHtmlWith(head: nil, body: rawString)
    }
    
    func getChapterTitle(_ chapterNumber: Int) -> String {
        return "No Chapter"
    }
    
    func getCover() -> UIImage {
        return UIImage()
    }
    
    func getBaseUrl(_ chapterNumbner: Int) -> URL {
        return baseUrl ?? URL(string: "")!
    }
}
