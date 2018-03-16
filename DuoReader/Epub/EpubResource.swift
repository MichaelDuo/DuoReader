//
//  EpubResource.swift
//  DuoReader
//
//  Created by Yuxi Dong on 16/03/2018.
//  Copyright © 2018 MichaelDuo. All rights reserved.
//

import Foundation
import AEXML

class EpubElement {
    var name: String
    var attributes: [String:String] = [:]
    var value: String?
    
    init(name: String, attributes: [String:String]?, value: String?){
        self.name = name
        self.attributes = attributes ?? self.attributes
        self.value = value
    }
}

class EpubBookMetadata {
    var title:EpubElement?
    var creator:EpubElement?
    var publisher:EpubElement?
    var date:EpubElement?
    var subject:EpubElement?
    var description:EpubElement?
    var rights:EpubElement?
    var identifier: EpubElement?
    var language:EpubElement?
    var cover:EpubElement?
    
    init(){}
}

class EpubItem:EpubElement {
    var id:String {
        return self.attributes["id"] ?? ""
    }
    
    var mediaType:String {
        return self.attributes["mediaType"] ?? ""
    }
    
    var isXML:Bool {
        return self.mediaType.contains("xml")
    }
    
    var url:URL
    
    
    init(id: String, url:URL, mediaType: String){
        self.url = url
        super.init(name: "item", attributes: ["id": id, "mediaType": mediaType], value: nil)
    }
    
    func getContent()->String {
        if isXML {
            return (try? String(contentsOf: url)) ?? ""
        }
        return ""
    }
}

class EpubBookManifest {
    var items:[EpubItem] = []
    
    init(){}
    
    func getItemWith(id: String)->EpubItem? {
        for item in items {
            if item.id == id {
                return item
            }
        }
        return nil
    }
}

class EpubItemRef:EpubElement {
    var idref:String {
        return self.attributes["idref"]!
    }
    init(idref: String){
        super.init(name: "itemref", attributes: ["idref": idref], value: nil)
    }
}

class EpubBookSpine {
    var itemrefs:[EpubItemRef] = []
    init(){}
}
