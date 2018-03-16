//
//  Txt.swift
//  DeerPark
//
//  Created by Yuxi Dong on 25/10/2017.
//  Copyright © 2017 XMind Ltd. All rights reserved.
//

import UIKit

class Txt: DPBookGenerator {
    let fileUrl:URL
    var rawString = ""
    
    required init(fileUrl: URL) {
        self.fileUrl = fileUrl
    }
    
    func parse(completion: ((DPBook) -> Void)?) {
        let book = TxtBook()
        rawString = (try? String(contentsOf: fileUrl)) ?? ""
        book.baseUrl = URL(fileURLWithPath: "")
        book.rawString = rawString
        completion?(book)
    }
}
