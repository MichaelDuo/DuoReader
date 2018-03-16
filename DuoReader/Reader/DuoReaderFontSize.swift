//
//  DuoReaderFontSize.swift
//  DuoReader
//
//  Created by Yuxi Dong on 16/03/2018.
//  Copyright © 2018 MichaelDuo. All rights reserved.
//

import UIKit

enum DPReaderFontSize: Int {
    case xs = 0
    case s
    case m
    case l
    case xl
    
    var identifier: String {
        switch self {
        case .xs : return "fontSizeOne"
        case .s : return "fontSizeTwo"
        case .m : return "fontSizeThree"
        case .l : return "fontSizeFour"
        case .xl : return "fontSizeFive"
        }
    }
    
    static var ordered : [DPReaderFontSize] {
        return [.xs, .s, .m, .l, .xl]
    }
    
    static func DPReaderFontSize(withIdentifier identifier: String) -> DPReaderFontSize? {
        var fontSize: DPReaderFontSize?
        switch identifier {
        case "fontSizeOne" : fontSize = .xs
        case "fontSizeTwo" : fontSize = .s
        case "fontSizeThree" : fontSize = .m
        case "fontSizeFour" : fontSize = .l
        case "fontSizeFive" : fontSize = .xl
        default : break
        }
        return fontSize
    }
}

enum DPReaderFontFamily: Int {
    case arial = 0
    case helvetica
    case times
    case georgia
    
    var identifier: String {
        switch self {
        case .arial : return "arial"
        case .helvetica : return "helvetica"
        case .times : return "times"
        case .georgia : return "georgia"
        }
    }
}
