//
//  EpubBook.swift
//  DuoReader
//
//  Created by Yuxi Dong on 16/03/2018.
//  Copyright © 2018 MichaelDuo. All rights reserved.
//

import Foundation
import SwiftSoup
import UIKit

class EpubBook: DPBook {
    
    var metadata = EpubBookMetadata()
    var manifest = EpubBookManifest()
    var spine = EpubBookSpine()
    
    var baseUrl: URL?
    
    var titleCache:[Int:String] = [:]
    
    var totalChapters: Int {
        return spine.itemrefs.count
    }
    
    init(){ }
    
    var chapterPercentages:[Double] = []
    
    func loadChapterPercentage(){
        chapterPercentages = []
        var chapterLengths:[Int] = []
        var totalLength = 0
        for chapterNum in 0..<totalChapters {
            let chapterLength = getChapter(chapterNum).count
            totalLength = totalLength + chapterLength
            chapterLengths.append(chapterLength)
        }
        
        for chapterLength in chapterLengths {
            chapterPercentages.append(Double(chapterLength) / Double(totalLength))
        }
    }
    
    func getChapter(_ chapterNumber: Int) -> String {
        return getHtml(chapterNumber: chapterNumber)
    }
    
    func getChapterTitle(_ chapterNumber: Int) -> String {
        if let title = titleCache[chapterNumber] {
            return title
        }
        let html = getHtml(chapterNumber: chapterNumber)
        var doc: Document!
        do {
            doc = try SwiftSoup.parse(html)
            let title = (try? doc.select("title").text()) ?? ""
            titleCache[chapterNumber] = title
            return title
        } catch let error {
            print(error)
            return ""
        }
    }
    
    func getCover() -> UIImage {
        if let item = metadata.cover {
            let itemId = item.value ?? ""
            let manifestItem = manifest.getItemWith(id: itemId)
            if let url = manifestItem?.url {
                do {
                    let data = try Data(contentsOf: url)
                    return UIImage(data: data) ?? UIImage()
                } catch let error {
                    print(error)
                }
            }
        }
        return UIImage()
    }
    
    func getBaseUrl(_ chapterNumber: Int) -> URL {
        let section = min(abs(chapterNumber), spine.itemrefs.count-1)
        let itemref = spine.itemrefs[section]
        guard let item = manifest.getItemWith(id: itemref.idref) else { return URL(string: "")! }
        return item.url.deletingLastPathComponent()
    }
    
    func getHtml(chapterNumber: Int) -> String {
        let section = min(abs(chapterNumber), spine.itemrefs.count-1)
        let itemref = spine.itemrefs[section]
        guard let item = manifest.getItemWith(id: itemref.idref) else { return "" }
        return item.getContent()
    }
}
