//
//  DuoReaderChapterList.swift
//  DuoReader
//
//  Created by Yuxi Dong on 16/03/2018.
//  Copyright © 2018 MichaelDuo. All rights reserved.
//

import UIKit

class DPReaderChapterList: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    
    var readerContainer: DPReaderContainer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension DPReaderChapterList {
    func setup(withContainer readerContainer: DPReaderContainer) {
        self.readerContainer = readerContainer
    }
}

extension DPReaderChapterList: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Save Config
        // Can not use saveConfig function because when this function is called, the chapter is not actually changed, but saveConfig will read the chapter in the current view as the current chapter.
        // TODO: This is a pretty bad way of doing this, refactor please.
        readerContainer.config.chapterNumber = indexPath.row
        readerContainer.config.chapterProgress = 0.0
        readerContainer.centerViewController.moveTo(chapterNumber: indexPath.row)
        dismiss(animated: true, completion: nil)
    }
}

extension DPReaderChapterList: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return readerContainer.book?.totalChapters ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = readerContainer.book?.getChapterTitle(indexPath.row) ?? ""
        return cell
    }
}
