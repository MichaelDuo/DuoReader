//
//  ProgressIndicator.swift
//  DeerPark
//
//  Created by Yuxi Dong on 27/11/2017.
//  Copyright © 2017 XMind Ltd. All rights reserved.
//

import UIKit

class ProgressIndicator: UIView {
    @IBOutlet weak var chapterNameLabel: UILabel!
    
    @IBOutlet weak var chapterProgressLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialization()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialization()
    }
    
    func initialization() {
        let xibView = Bundle.main.loadNibNamed("ProgressIndicator", owner: self, options: nil)?.first as! UIView
        xibView.frame = self.bounds
        xibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(xibView)
    }

}
