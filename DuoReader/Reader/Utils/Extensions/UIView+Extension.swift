//
//  UIView+Extension.swift
//  Deerpark
//
//  Created by Yuxi Dong on 13/09/2017.
//  Copyright © 2017 XMind. All rights reserved.
//

import UIKit

enum Direction {
    case top, left, right, bottom
}

extension UIView {
    func slideIn(from direction:Direction, animate:Bool, duraction:Double?, completion: ((Bool)->Void)?){
        isHidden = false
//        if animate {
//            UIView.animate(withDuration: duraction ?? 0, animations: {
//                self.frame = getShowFrame(self.frame, from: direction)
//            }, completion: completion)
//        } else {
//            self.frame = getShowFrame(self.frame, from: direction)
//            completion?(true)
//        }
    }
    
    func slideOut(to direction:Direction, animate:Bool, duraction:Double?, completion: ((Bool)->Void)?){
        self.isHidden = true
//        if animate {
//            UIView.animate(withDuration: duraction ?? 0, animations: {
//                self.frame = getHideFrame(self.frame, to: direction)
//            }) { (finished) in
//                completion?(finished)
//            }
//        } else {
//            self.frame = getHideFrame(self.frame, to: direction)
//            completion?(true)
//        }
    }
    
    func removeAllSubviews(){
        for v in self.subviews {
            v.removeFromSuperview()
        }
    }
}

func getHideFrame(_ frame: CGRect, to direction: Direction)->CGRect{
    var frame = frame
    switch direction {
    case .top:
        frame.origin.y -= frame.size.height
    case .right:
        frame.origin.x += frame.size.width
    case .bottom:
        frame.origin.y += frame.size.height
    case .left:
        frame.origin.x -= frame.size.width
    }
    return frame
}

func getShowFrame(_ frame: CGRect, from direction: Direction)->CGRect{
    var frame = frame
    switch direction {
    case .top:
        frame.origin.y += frame.size.height
    case .right:
        frame.origin.x -= frame.size.width
    case .bottom:
        frame.origin.y -= frame.size.height
    case .left:
        frame.origin.x += frame.size.width
    }
    return frame
}
