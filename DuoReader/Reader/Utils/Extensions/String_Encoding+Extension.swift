//
//  String_Encoding+Extension.swift
//  Deerpark
//
//  Created by Yuxi Dong on 15/09/2017.
//  Copyright © 2017 XMind. All rights reserved.
//

import UIKit

extension String.Encoding {
    static let gb_18030_2000 = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)))
}
