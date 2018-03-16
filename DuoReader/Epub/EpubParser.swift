//
//  EpubParser.swift
//  DuoReader
//
//  Created by Yuxi Dong on 16/03/2018.
//  Copyright © 2018 MichaelDuo. All rights reserved.
//

import AEXML

protocol EpubParserDataSource {
    func getFileUrl(path:String)->URL
    func getFileWith(path:String)->String?
}

class EpubParser {
    var book = EpubBook()
    let dataSource:EpubParserDataSource
    
    private var rootFileDir:URL?
    
    init(dataSource:EpubParserDataSource){
        self.dataSource = dataSource
    }
    
    func parse()->EpubBook{
        startParse()
        return book
    }
    
    func startParse(){
        parseContainer()
    }
    
    func parseContainer(){
        guard let containerData = dataSource.getFileWith(path: "META-INF/container.xml") else {
            return
        }
        let xml = try? AEXMLDocument(xml: containerData)
        guard let rootFilePath = xml?.root["rootfiles"]["rootfile"].attributes["full-path"] else {
            return
        }
        parseRootfile(rootFilePath)
    }
    
    // TODO: Actually Implement This
    func parseRootfile(_ rootFilePath:String){
        guard let rootFile = dataSource.getFileWith(path: rootFilePath) else { return }
        rootFileDir = dataSource.getFileUrl(path: rootFilePath).deletingLastPathComponent()
        book.baseUrl = rootFileDir!
        
        guard let xml = try? AEXMLDocument(xml: rootFile) else { return }
        for child in xml.root["metadata"].children {
            switch child.name {
            case "dc:title":
                book.metadata.title = EpubElement(name: "title", attributes: nil, value: child.value)
            case "dc:creator":
                book.metadata.title = EpubElement(name: "creator", attributes: nil, value: child.value)
            case "dc:publisher":
                book.metadata.title = EpubElement(name: "publisher", attributes: nil, value: child.value)
            case "dc:date":
                book.metadata.title = EpubElement(name: "date", attributes: nil, value: child.value)
            case "dc:subject":
                book.metadata.title = EpubElement(name: "subject", attributes: nil, value: child.value)
            case "dc:description":
                book.metadata.title = EpubElement(name: "description", attributes: nil, value: child.value)
            case "dc:rights":
                book.metadata.title = EpubElement(name: "rights", attributes: nil, value: child.value)
            case "dc:identifier":
                book.metadata.title = EpubElement(name: "identifier", attributes: nil, value: child.value)
            case "dc:language":
                book.metadata.title = EpubElement(name: "language", attributes: nil, value: child.value)
            case "meta":
                if let name = child.attributes["name"] {
                    switch name {
                    case "cover":
                        book.metadata.cover = EpubElement(name: "meta", attributes: child.attributes, value: child.attributes["content"])
                    default: continue
                    }
                }
            default:
                print("Unrecognized element \(child.name)")
            }
        }
        
        for item in xml.root["manifest"].children {
            guard let id:String = item.attributes["id"] else { continue }
            guard let href:String = item.attributes["href"] else { continue }
            let url = URL(fileURLWithPath: href, relativeTo: rootFileDir)
            guard let mediaType:String = item.attributes["media-type"] else { continue }
            let epubItem = EpubItem(id: id, url: url, mediaType: mediaType)
            book.manifest.items.append(epubItem)
        }
        
        for itemref in xml.root["spine"].children {
            guard let idref:String = itemref.attributes["idref"] else { continue }
            let epubItemRef = EpubItemRef(idref: idref)
            book.spine.itemrefs.append(epubItemRef)
        }
    }
}
