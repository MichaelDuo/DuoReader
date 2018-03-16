//
//  DuoReaderChapter.swift
//  DuoReader
//
//  Created by Yuxi Dong on 16/03/2018.
//  Copyright © 2018 MichaelDuo. All rights reserved.
//

import UIKit

class DPReaderChapter: UICollectionViewCell {
    var readerContainer: DPReaderContainer!
    var webView: DPWebView!
    var chapterNumber: Int!
    
    // TODO: Have a chapter title getter
    
    var lastScroll: Date = Date()
    var lastTouch = Date()
    
    var pageTags:[UIView] = []
    
    
    var webViewFinishLoadCallbacks: [()->Void] = []
    var webViewFinishLoad = false {
        didSet {
            if oldValue == false && webViewFinishLoad == true {
                while self.webViewFinishLoadCallbacks.count>0 {
                    self.webViewFinishLoadCallbacks.removeFirst()()
                }
            }
        }
    }
    
    deinit {
        webView.scrollView.delegate = nil
        webView.delegate = nil
    }
}

// Class Public Methods
extension DPReaderChapter {
    func prepare(){
        webViewFinishLoad = false
        webViewFinishLoadCallbacks = []
        
        setupViews()
        loadContent()
    }
    
    func setFontSize(_ fontSize: DPReaderFontSize){
        webView.js("Reader.changeFontSize('\(fontSize.identifier)')")
        pageSizeAffected()
    }
    
    func setFontFamily(_ fontFamily: DPReaderFontFamily){
        webView.js("Reader.changeFontFamily('\(fontFamily.identifier)')")
        pageSizeAffected()
    }
    
    func afterLoaded(callback: @escaping ()->Void){
        if webViewFinishLoad {
            callback()
        } else {
            webViewFinishLoadCallbacks.append(callback)
        }
    }
    
    func loadChapterConfig(){
        if !webView.isLoading {
            setFontSize(readerContainer.config.fontSize)
            setFontFamily(readerContainer.config.fontFamily)
            if chapterNumber == readerContainer.config.chapterNumber {
                setProgress(Float(readerContainer.config.chapterProgress), animated: false)
            }
        } else {
            print("Warning: Load Chapter Config Will Not Have Effect Because WebView Is Still Loading.")
        }
    }
    
    func getProgress()->Float{
        if webViewFinishLoad == false {
            return 0.0
        }
        var progress:Float = 0.0
        if readerContainer.centerViewController.scrollDirection == .horizontal {
            progress = Float(webView.scrollView.contentOffset.x / (webView.scrollView.contentSize.width - frame.width))
        } else {
            progress = Float(webView.scrollView.contentOffset.y / (webView.scrollView.contentSize.height - frame.height))
        }
        if progress.isNaN {
            return 0.0
        } else {
            return progress
        }
    }
    
    func setProgress(_ newProgress:Float, animated: Bool){
        afterLoaded {
            if self.readerContainer.centerViewController.scrollDirection == .horizontal {
                let offset = self.getPageOffset(pageWidth: Double(self.frame.width), totalWidth: Double(self.webView.scrollView.contentSize.width), percentage: Double(newProgress))
                self.webView.scrollView.setContentOffset(CGPoint.init(x: offset, y: 0), animated: animated)
            } else {
                let offset = self.getPageOffset(pageWidth: Double(self.frame.height), totalWidth: Double(self.webView.scrollView.contentSize.height), percentage: Double(newProgress))
                self.webView.scrollView.setContentOffset(CGPoint.init(x: 0, y: offset), animated: animated)
            }
        }
    }
}

// Class Private Functions
extension DPReaderChapter {
    private func loadContent(){
        webView.alpha = 0
        if let book = readerContainer.book {
            let content = book.getChapter(chapterNumber)
            let baseUrl = book.getBaseUrl(chapterNumber)
            webView.loadHTMLString(content, baseURL: baseUrl)
        } else {
            let request = URLRequest(url: readerContainer.fileUrl)
            webView.loadRequest(request)
        }
    }
    
    private func eventHandler(event: String, data: [String: Any]?)->String {
        if event=="tap" {
            readerContainer.centerViewController.chapterDidTap(tapSection: .middle)
        }
        return ""
    }
    
    private func addPageTags(){
        // TODO: Should do this after webview loaded, use after load function
        if readerContainer.centerViewController.scrollDirection == .horizontal {
            return
        }
        // Remove Current Tags
        while(pageTags.count>0) {
            let pageTag = pageTags.removeFirst()
            pageTag.removeFromSuperview()
        }
        
        // Add New Tags
        let contentHeight = Double(webView.contentHeight)
        var willProcessedHeight = 0.0
        var count = 1
        
        afterLoaded {
            while willProcessedHeight < contentHeight {
                let pageTag = UILabel()
                pageTag.text = "\(count)"
                pageTag.frame = CGRect.init(x: 3, y: willProcessedHeight, width: 100, height: 100)
                self.webView.scrollView.addSubview(pageTag)
                count = count + 1
                willProcessedHeight = willProcessedHeight + Double(self.frame.height)
                self.pageTags.append(pageTag)
            }
        }
    }
    
    private func getPageOffset(pageWidth: Double, totalWidth: Double, percentage: Double)->Double{
        let validWidthForProgress = totalWidth-pageWidth
        let absPosition = validWidthForProgress * percentage
        var offset = 0.0
        if(abs(percentage)>=1){
            return validWidthForProgress
        }
        while(offset<=validWidthForProgress){
            if(absPosition <= offset+pageWidth){
                return offset
            }
            offset+=pageWidth
        }
        return 0
    }
    
    private func injectJS(){
        let cssFileUrl = Bundle.main.url(forResource: "style", withExtension: "css")
        let jsFileUrl = Bundle.main.url(forResource: "ReaderJS/reader.bundle", withExtension: "js")
        self.webView.injectJS(url: jsFileUrl!)
        self.webView.js("new Reader().mountWithTag('body');")
        self.webView.js("$('head style').remove();")
        self.webView.injectCSS(url: cssFileUrl!)
    }
    
    private func pageSizeAffected(){
        addPageTags()
    }
    
    private func updateProgress(){
        self.readerContainer.centerViewController.chapterProgressUpdated(percentage: self.getProgress())
    }
    
    private func saveConfig(){
        readerContainer.centerViewController.saveConfig()
    }
}

enum TapSection {
    case left, middle, right
}

// MARK: - Event Targets
extension DPReaderChapter{
    @objc func didTap(sender: UITapGestureRecognizer){
        //        print("Yoooooo---")
        //        print(sender.location(in: webView))
        //        let totalSection = 3
        //        for i in 0..<totalSection {
        //            let interval = 1.0 / Double(totalSection)
        //
        //
        //        }
        readerContainer.centerViewController.chapterDidTap(tapSection: .middle)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer {
            let elapsed = Double(Date().timeIntervalSince(lastScroll))
            if elapsed <= 0.2 && readerContainer.centerViewController.scrollDirection == .vertical {
                print("Should not receive")
                return false
            }
        }
        return true
    }
}

// MARK: - Views Setup
extension DPReaderChapter {
    private func setupViews(){
        self.backgroundColor = UIColor.white
        setupWebView()
        addEvents()
    }
    
    private func setupWebView(){
        if webView != nil { webView.removeFromSuperview() }
        webView = DPWebView()
        webView.scrollView.bounces = false
        webView.delegate = self
        webView.scrollView.delegate = self
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        webView.scrollView.backgroundColor = UIColor.white
        addSubview(webView)
        
        if readerContainer.centerViewController.scrollDirection == .horizontal {
            webView.paginationMode = .leftToRight
            webView.scrollView.isPagingEnabled = true
        } else {
            webView.paginationMode = .topToBottom
            webView.scrollView.isPagingEnabled = false
        }
    }
    
    private func addEvents(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        tap.numberOfTapsRequired = 1
        tap.delegate = self
        webView.addGestureRecognizer(tap)
    }
}

// MARK: - UIWebViewDelegate
extension DPReaderChapter : UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIView.animate(withDuration: 0.2) {
            webView.alpha = 1
        }
        
        injectJS()
        self.loadChapterConfig()
        self.addPageTags()
        
        /*
         This is a fix when previous chapter contains images,
         when previous chapter has images, webviewfinishload calls back
         when the images is not fully loaded, however, if we set the progress
         before the chapter is fully loaded, the progress will be incorrect.
         
         We will give it some time to let it actually finish load all the stuff
         */
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.webViewFinishLoad = true
        }
    }
}

// MARK: - UIScrollViewDelegate
extension DPReaderChapter : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        lastScroll = Date()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("Save Config")
        saveConfig()
        updateProgress()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension DPReaderChapter : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - JS Bridge
extension DPReaderChapter {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        guard
            let webView = webView as? DPWebView,
            let scheme = request.url?.scheme
            else {
                return true
        }
        
        guard let url = request.url else { return false }
        
        if scheme == "app" {
            print(url.absoluteString)
            let messageType = url.host ?? ""
            var messageBody = url.path
            
            let i = messageBody.index(messageBody.startIndex, offsetBy: 1)
            messageBody = String(messageBody[i..<messageBody.endIndex])
            
            let json = try? JSONSerialization.jsonObject(with: messageBody.data(using: .utf8)!, options: [])
            
            guard let dic = json as? [String: Any] else { return false }
            let messageId = dic["id"] as! String
            
            var res:[String:Any] = [:]
            
            if messageType == "event" {
                res["message"] = eventHandler(event: dic["message"] as! String, data: nil)
            }
            
            res["code"] = 200
            
            let jsonData = try! JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
            let response = String(data: jsonData, encoding: .utf8) ?? ""
            webView.respond(id: messageId, message: response.toBase64())
            return false
        }
        return true
    }
}
