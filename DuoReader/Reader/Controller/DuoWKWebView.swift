//
//  DuoWKWebView.swift
//  DuoReader
//
//  Created by Yuxi Dong on 16/03/2018.
//  Copyright © 2018 MichaelDuo. All rights reserved.
//

import UIKit
import WebKit

class DPWKWebView: WKWebView {
    
}

extension DPWKWebView {
    func stringByEvaluatingJavaScript(from javascriptString: String){
        self.evaluateJavaScript(javascriptString) { (result, error) in
            
        }
    }
}
