//
//  BottomMenuView.swift
//  Deerpark
//
//  Created by Yuxi Dong on 12/09/2017.
//  Copyright © 2017 XMind. All rights reserved.
//

import UIKit

@objc protocol BottomMenuDelegate: class {
    @objc optional func pageSliderValueChanged(value:Float)
    @objc optional func pageSliderValueDoneChanging(value:Float)
    @objc optional func pageSliderValueStartChanging(value:Float)
    @objc optional func increaseFontSize()
    @objc optional func decreaseFontSize()
    @objc optional func BottomMenuSwitchVH()
    @objc optional func BottomMenuShowIndex()
    @objc optional func BottomMenuSliderTouchDown()
    @objc optional func BottomMenuSliderTouchUp()
}

class BottomMenu: UIView {
    
    var delegate:BottomMenuDelegate?
    
    @IBOutlet weak var pageSlider: UISlider!
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
        xibView = Bundle.main.loadNibNamed("BottomMenu", owner: self, options: nil)?.first as! UIView
        xibView.frame = self.bounds
        xibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        composeShadow()
        self.addSubview(xibView)
    }
}

extension BottomMenu {
    func composeShadow(){
        xibView.layer.masksToBounds = false
        xibView.layer.shadowOffset = CGSize(width: 0, height: -1)
        xibView.layer.shadowRadius = 5
        xibView.layer.shadowOpacity = 0.2
    }
    
    func composeBackground(){
        let background = UIImageView(frame: bounds)
        background.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
        self.addSubview(background)
    }
    

    @IBAction func sliderValueChanged(_ sender: Any){
        delegate?.pageSliderValueChanged?(value: pageSlider.value)
    }
    
    @IBAction func increaseFontSize(){
        delegate?.increaseFontSize?()
    }
    
    @IBAction func decreaseFontSize(){
        delegate?.decreaseFontSize?()
    }
    
    @IBAction func switchVH(){
        delegate?.BottomMenuSwitchVH?()
    }
    
    @IBAction func showIndex(){
        delegate?.BottomMenuShowIndex?()
    }
    
    @IBAction func touchUp(){
        delegate?.BottomMenuSliderTouchUp?()
    }
    
    @IBAction func touchDown(){
        delegate?.BottomMenuSliderTouchDown?()
    }
    
    
}

