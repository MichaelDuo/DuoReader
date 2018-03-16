//
//  TopMenu.swift
//  Deerpark
//
//  Created by Yuxi Dong on 12/09/2017.
//  Copyright © 2017 XMind. All rights reserved.
//

import UIKit

@objc protocol TopMenuDelegate: class {
    @objc optional func TopMenuBack()
}

class TopMenu: UIView {
    
    weak var delegate: TopMenuDelegate?
    
    var rightSideButtons: [UIButton] = []
    var xibView:UIView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialization()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialization()
    }
    
    func initialization() {
        xibView = Bundle.main.loadNibNamed("TopMenu", owner: self, options: nil)?.first as! UIView
        xibView.frame = self.bounds
        xibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        composeShadow()
        self.addSubview(xibView)
    }
}

// Compose Views
extension TopMenu {
    func composeShadow(){
        xibView.layer.masksToBounds = false
        xibView.layer.shadowOffset = CGSize(width: 0, height: 1)
        xibView.layer.shadowRadius = 5
        xibView.layer.shadowOpacity = 0.2
    }
}

// Target Actions
extension TopMenu {
    @IBAction func back(){
        delegate?.TopMenuBack?()
    }
}
