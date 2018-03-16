//
//  DuoWebView.swift
//  DuoReader
//
//  Created by Yuxi Dong on 16/03/2018.
//  Copyright © 2018 MichaelDuo. All rights reserved.
//

import UIKit
import WebKit

class DPWebView: UIWebView {
    var contentHeight:Int {
        let res = cmd("document.body.offsetHeight") ?? "0"
        return Int(res)!
    }
    
    func respond(id: String, message: String){
        js("Reader.bridge.appMessage('\(id)', '\(message)')")
    }
    
    func js(_ cmd: String){
        self.stringByEvaluatingJavaScript(from: cmd)
    }
    
    func cmd(_ cmd: String)->String?{
        return self.stringByEvaluatingJavaScript(from: cmd)
    }
    
    func injectCSS(url: URL){
        do {
            let cssString = try String(contentsOf: url)
            let jsString = "var style=document.createElement('style'); style.innerHTML = `\(cssString)`; document.head.appendChild(style);"
            js(jsString)
        } catch let error {
            print(error)
        }
    }
    
    func injectJS(url: URL){
        do {
            let jsString = try String(contentsOf: url)
            js(jsString)
        } catch let error {
            print(error)
        }
    }
}
