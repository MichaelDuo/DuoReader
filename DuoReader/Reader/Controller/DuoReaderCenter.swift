//
//  DuoReaderCenter.swift
//  DuoReader
//
//  Created by Yuxi Dong on 16/03/2018.
//  Copyright © 2018 MichaelDuo. All rights reserved.
//

import UIKit

let reuseCellIdentifier = "DPReaderChapter"

enum ScrollDirection {
    case vertical
    case horizontal
}

// MARK: - DPReaderCenter
class DPReaderCenter: UIViewController, UICollectionViewDelegate {
    var readerContainer: DPReaderContainer!
    var collectionView: UICollectionView!
    var collectionViewLayout = UICollectionViewFlowLayout()
    var collectionViewConstraints:[NSLayoutConstraint] = []
    @IBOutlet var topMenu:TopMenu!
    @IBOutlet var bottomMenu:BottomMenu!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var bottomArea: UIView!
    @IBOutlet weak var topArea: UIView!
    
    @IBOutlet weak var progressIndicator: ProgressIndicator!
    
    var fontMenu:FontMenu!
    
    var isDragging = false
    var prevChapterNumber:Int?
    
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    
    var scrollDirection: ScrollDirection = .horizontal {
        willSet {
            saveConfig()
        }
        
        didSet {
            let currentChapterNumber = currentChapter?.chapterNumber
            updateCollectionView()
            if scrollDirection != oldValue {
                /*
                 HACKY!!!
                 Potential bug: this block will be called based on the knowledge that updateCollectionView
                 will change the constraints and thus trigger didlayoutsubviews callback, this will not be
                 true if layout is not changed.
                 */
                isLayingout = true
            }
            self.afterNextLayoutSubviews {
                print("Loading Config")
                self.loadConfig()
                self.reloadChapter(chapterNumber: currentChapterNumber!)
            }
        }
    }
    
    // After Layout Job Control
    private var isLayingout = false
    private var afterLayoutJobs:[()->Void] = []
    private func afterNextLayoutSubviews(job: @escaping ()->Void){
        if isLayingout {
            afterLayoutJobs.append(job)
        } else {
            job()
        }
    }
    override func viewDidLayoutSubviews() {
        isLayingout = false
        while self.afterLayoutJobs.count>0 {
            afterLayoutJobs.removeFirst()()
        }
    }
    override func viewWillLayoutSubviews() {
        isLayingout = true
    }
    
    var currentChapter: DPReaderChapter? {
        let currentCellIndexPath = getCurrentIndexPath()
        let chapter = collectionView.cellForItem(at: currentCellIndexPath) as! DPReaderChapter?
        return chapter
    }
    
    var fontSize: DPReaderFontSize = DPReaderFontSize.m {
        didSet {
            currentChapter?.setFontSize(fontSize)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadConfig()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.alpha = 0
        let currentChapterNumber = readerContainer.config.chapterNumber // Get saved config
        coordinator.animate(alongsideTransition: { (context) in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: {
            (context) in
            self.reloadChapter(chapterNumber: currentChapterNumber)
            self.loadConfig()
            UIView.animate(withDuration: 0.2, animations: {
                self.collectionView.alpha = 1
            })
        })
    }
}

// MARK: - Class Methods
extension DPReaderCenter {
    func moveTo(progress: Double){
        if let book = readerContainer.book {
            let progressPoint = book.getChapterNumAndChapterProgress(progress: progress)
            moveTo(chapterNumber: progressPoint.0, chapterProgress: progressPoint.1)
        } else {
            moveTo(chapterNumber: 0, chapterProgress: progress)
        }
    }
    
    func moveTo(chapterNumber: Int, chapterProgress: Double){
        readerContainer.config.chapterNumber = chapterNumber
        readerContainer.config.chapterProgress = chapterProgress
        moveTo(chapterNumber: chapterNumber)
    }
    
    func moveTo(chapterNumber: Int) {
        collectionView.alpha = 0
        let indexPath = IndexPath(row: chapterNumber, section: 0)
        if scrollDirection == .horizontal {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        } else {
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        }
        reloadChapter(chapterNumber: chapterNumber) // Trigger chapter to load current progress
        let targetChapter = collectionView.cellForItem(at: IndexPath(row: chapterNumber, section: 0)) as! DPReaderChapter
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            UIView.animate(withDuration: 0.2, animations: {
                self.collectionView.alpha = 1
            })
        }
        
        targetChapter.afterLoaded {
            self.updateProgressSlider()
            self.updateProgressLabel()
        }
    }
    
    func getProgress()->Double{
        var progress = 0.0
        if let currentChapter = self.currentChapter {
            let chapterNumber = Int((currentChapter.chapterNumber))
            let chapterProgress = Double((currentChapter.getProgress()))
            if let book = readerContainer.book {
                progress = (book.getProgress(chapterNumber: chapterNumber, chapterProgress: chapterProgress))
            } else {
                progress = chapterProgress
            }
        } else {
            print("Get Progress Failed Because Current Chapter Is Nil")
        }
        return progress
    }
    
    func reloadChapter(chapterNumber: Int){
        let chapterIndex = IndexPath(row: chapterNumber, section: 0)
        collectionView.reloadItems(at: [chapterIndex])
    }
    
    func getCurrentIndexPath()->IndexPath {
        let indexPaths = collectionView.indexPathsForVisibleItems
        return indexPaths.first ?? IndexPath(row: 0, section: 0)
    }
    
    func getConfig() -> DPReaderConfig {
        var config = DPReaderConfig()
        config.chapterNumber = currentChapter?.chapterNumber ?? 0
        config.chapterProgress = Double(currentChapter?.getProgress() ?? 0.0)
        config.fontSize = fontSize
        return config
    }
    
    func saveConfig(){
        // TODO: Have a setter maybe?
        readerContainer.config = getConfig()
    }
}

// MARK: - View Setup Methods
extension DPReaderCenter {
    private func setupViews() {
        setupBackground()
        setupCollectionView()
        setupMenu()
        updateCollectionView()
    }
    
    private func loadConfig() {
        let config = readerContainer.config!
        moveTo(chapterNumber: config.chapterNumber)
        
        // scroll direction will be stored in config
        if scrollDirection == .horizontal {
            progressLabel.isHidden = false
        } else {
            progressLabel.isHidden = true
        }
    }
    
    private func setupBackground() {
        view.backgroundColor = UIColor.white
    }
    
    private func setupCollectionView() {
        collectionViewLayout.sectionInset = .zero
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DPReaderChapter.self, forCellWithReuseIdentifier: reuseCellIdentifier)
        
        collectionView.collectionViewLayout = collectionViewLayout // Need this?
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView.isScrollEnabled = true
        collectionView.backgroundColor = UIColor.white
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionViewConstraints = [
            iPhoneX ? NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 0) : NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: collectionView, attribute: .trailing, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: collectionView, attribute: .leading, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: 0)
        ]
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate(collectionViewConstraints)
        view.sendSubview(toBack: collectionView)
    }
    
    private func setupMenu() {
        let bundle = Bundle.main
        topMenu.delegate = self
        topMenu.slideOut(to: .top, animate: false, duraction: 0, completion: nil)
        
        bottomMenu.delegate = self
        bottomMenu.slideOut(to: .bottom, animate: false, duraction: 0, completion: nil)
        
        bottomArea.isHidden = true
        topArea.isHidden = true
        
        fontMenu = UINib(nibName: "FontMenu", bundle: bundle).instantiate(withOwner: self, options: nil).first as! FontMenu
        self.view.addSubview(fontMenu)
        fontMenu.slideOut(to: .bottom, animate: false, duraction: 0, completion: nil)
    }
    
    private func updateCollectionView() {
        if scrollDirection == .horizontal {
            collectionViewLayout.scrollDirection = .horizontal
            collectionViewConstraints[0].constant = 30.0 // Top Constraint
            collectionViewConstraints[2].constant = -30.0 // Bottom Constraint
        } else {
            collectionViewLayout.scrollDirection = .vertical
            collectionViewConstraints[0].constant = 0.0 // Top Constraint
            collectionViewConstraints[2].constant = 0.0 // Bottom Constraint
        }
        NSLayoutConstraint.activate(collectionViewConstraints)
    }
    
    private func updateProgressSlider(){
        bottomMenu.pageSlider.value = Float(getProgress())
    }
    
    func updateProgressLabel(){
        let progress = getProgress()
        progressLabel.text = "\(String(format: "%.2f", progress * 100))%"
    }
}

// MARK: - UICollectionViewDataSource
extension DPReaderCenter : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return readerContainer.book?.totalChapters ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let chapter = collectionView.dequeueReusableCell(withReuseIdentifier: reuseCellIdentifier, for: indexPath) as! DPReaderChapter
        chapter.chapterNumber = indexPath.row
        chapter.readerContainer = readerContainer
        chapter.prepare()
        return chapter
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let currentChapterNumber = indexPath.row
        let cell = cell as! DPReaderChapter
        if let prevChapterNumber = prevChapterNumber {
            if currentChapterNumber < prevChapterNumber && isDragging {
                cell.alpha = 0
                cell.afterLoaded {
                    cell.setProgress(1, animated: false)
                    UIView.animate(withDuration: 0.2) {
                        cell.alpha = 1
                    }
                }
            } else {
                cell.setProgress(0, animated: false)
            }
        }
        cell.loadChapterConfig() // TODO: Change Routine, probably should not call this method directly
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DPReaderCenter : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}

// MARK: - TopMenuDelegate
extension DPReaderCenter : TopMenuDelegate {
    func TopMenuBack() {
        readerContainer.dismiss(animated: true, completion: nil)
    }
}

// MARK: - BottomMenuDelegate
extension DPReaderCenter : BottomMenuDelegate {
    func increaseFontSize(){
        let currentFontSizeIndex = DPReaderFontSize.ordered.index(of: fontSize)
        let intIndex = DPReaderFontSize.ordered.startIndex.distance(to: currentFontSizeIndex!)
        let targetIndex = min(intIndex+1, DPReaderFontSize.ordered.count-1)
        fontSize = DPReaderFontSize.ordered[targetIndex]
    }
    
    func decreaseFontSize() {
        let currentFontSizeIndex = DPReaderFontSize.ordered.index(of: fontSize)
        let intIndex = DPReaderFontSize.ordered.startIndex.distance(to: currentFontSizeIndex!)
        let targetIndex = max(intIndex-1, 0)
        fontSize = DPReaderFontSize.ordered[targetIndex]
    }
    
    func pageSliderValueChanged(value:Float){
        progressIndicator.chapterProgressLabel.text = "\(String(format: "%.2f", value * 100))%"
        if let progressPoint = readerContainer.book?.getChapterNumAndChapterProgress(progress: Double(value)) {
            let chapterName = readerContainer.book?.getChapterTitle(progressPoint.0)
            progressIndicator.chapterNameLabel.text = chapterName
        }
    }
    
    func BottomMenuSwitchVH(){
        if scrollDirection == .horizontal {
            scrollDirection = .vertical
        } else {
            scrollDirection = .horizontal
        }
    }
    
    func BottomMenuShowIndex(){
        let storyboard = UIStoryboard(name: "Reader", bundle: nil)
        let chapterList = storyboard.instantiateViewController(withIdentifier: "ChapterList") as! DPReaderChapterList
        chapterList.setup(withContainer: readerContainer)
        self.present(chapterList, animated: true, completion: nil)
    }
    
    func BottomMenuSliderTouchDown() {
        progressIndicator.isHidden = false
    }
    
    func BottomMenuSliderTouchUp() {
        progressIndicator.isHidden = true
        moveTo(progress: Double(bottomMenu.pageSlider.value))
    }
}

// MARK: - DPReaderChapter Will Call Those Functions
extension DPReaderCenter {
    func chapterProgressUpdated(percentage: Float) {
        updateProgressSlider()
        updateProgressLabel()
        
    }
    
    func chapterDidTap(tapSection: TapSection) {
        if topMenu.isHidden {
            topMenu.slideIn(from: .top, animate: true, duraction: 0.3, completion: nil)
            bottomMenu.slideIn(from: .bottom, animate: true, duraction: 0.3, completion: nil)
            readerContainer.showStatusBar = true
            bottomArea.isHidden = false
            topArea.isHidden = false
        } else {
            topMenu.slideOut(to: .top, animate: true, duraction: 0.3, completion: nil)
            bottomMenu.slideOut(to: .bottom, animate: true, duraction: 0.3, completion: nil)
            fontMenu.slideOut(to: .bottom, animate: true, duraction: 0.3, completion: nil)
            readerContainer.showStatusBar = false
            bottomArea.isHidden = true
            topArea.isHidden = false
        }
    }
}

extension DPReaderCenter: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        /*
         When collection view scroll, it means the chapter will change,
         however, when user keep swiping when chapter just changed, the webview
         will not respond to touch events, it will cause user keep switching
         the chapter, which is not desired, so we disable use interaction when
         collection views scroll view start moving, and enable it when deceleration
         finished.
         */
        collectionView.isUserInteractionEnabled = false
        isDragging = true
        prevChapterNumber = currentChapter?.chapterNumber
        // Chapter is switching, save config for next chapter
        saveConfig()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isDragging = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            /*
             collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
             AND
             scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
             Won't call for some mysterious reason
             this block will be a safe guard for that case
             */
            self.collectionView.isUserInteractionEnabled = true
            // Maybe update progress here???
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        collectionView.isUserInteractionEnabled = true
        updateProgressSlider()
        updateProgressLabel()
        saveConfig()
    }
}
