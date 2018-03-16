//
//  VerticalSlider.swift
//  DeerPark
//
//  Created by Yuxi Dong on 17/10/2017.
//  Copyright © 2017 XMind Ltd. All rights reserved.
//

import UIKit

protocol VerticalSliderDelegate : class {
    func sliderValueChanged(value: Float)
}

class VerticalSlider: UIView {
    var slider:UISlider!
    weak var delegate:VerticalSliderDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        composeSlider()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func composeSlider(){
        slider = UISlider()
        slider.frame = CGRect(x: -frame.height/2+(frame.width/2), y: (frame.height/2)-(frame.width/2), width: frame.height, height: frame.width)
        slider.transform = CGAffineTransform(rotationAngle: CGFloat((Double.pi/2)))
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        self.addSubview(slider)
    }
    
    func setValue(_ value: Float){
        slider.value = value
    }
    
    @objc func sliderValueChanged(){
        delegate?.sliderValueChanged(value: slider.value)
    }
}
