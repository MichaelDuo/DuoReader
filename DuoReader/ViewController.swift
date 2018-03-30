//
//  ViewController.swift
//  DuoReader
//
//  Created by Yuxi Dong on 16/03/2018.
//  Copyright © 2018 MichaelDuo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func DemoButtonClick(_ sender: Any) {
        let EpubURL = Bundle.main.url(forResource: "The Silver Chair", withExtension: "epub")
        DPReader().presentReader(parentViewController: self, withFileUrl: EpubURL!, andConfig: DPReaderConfig())
    }
    
}

