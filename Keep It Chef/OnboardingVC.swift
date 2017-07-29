//
//  OnboardingVC.swift
//  Keep It Chef
//
//  Created by amrun on 28/07/17.
//  Copyright © 2017 NXTLVL. All rights reserved.
//

import UIKit

class OnboardingVC: OnboardingViewController {

    @IBOutlet weak var skip: UIButton!
    
    override func viewDidLoad() {
        
        presenter = screenPresenter()
        presenter.onOnBoardingFinished = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        
        super.viewDidLoad()
        setupNextButton()

        // Do any additional setup after loading the view.
    }
    
    open func setupNextButton() {
        skip.setTitle(NSLocalizedString("SKIP", comment: ""), for: .normal)
        skip.setTitleColor(.white, for: .normal)
        skip.addTarget(self, action: #selector(nextTapped(sender:)), for: .touchUpInside)
    }
    
    override open func pageChanged(to page: Int) {
        pageControl?.currentPage = page
        skip.setTitle(page == presenter.pageCount - 1 ? NSLocalizedString("GET STARTED", comment: "") : NSLocalizedString("SKIP", comment: ""), for: .normal)
    }
    
    open func nextTapped(sender: UIButton) {
        if currentPage == presenter.pageCount - 1 {
            self.dismiss(animated: true, completion: nil)
            print("done")
        } else {
//            skipOnboarding()
//            currentPage = currentPage + 1
//            let index = IndexPath(row: currentPage, section: 0)
//            collectionView?.scrollToItem(at: index, at: UICollectionViewScrollPosition.left, animated: true)
            self.dismiss(animated: true, completion: nil)
            print("skip")
        }
    }

}

class screenPresenter: BasePresenter {
    
    required override init() {
        super.init()
        
        model = [
            OnboardingSlide(titleText: "",
                            bodyText: "",
                            image: #imageLiteral(resourceName: "screen1")),
            OnboardingSlide(titleText: "",
                            bodyText: "",
                            image: #imageLiteral(resourceName: "screen2")),
            OnboardingSlide(titleText: "",
                            bodyText: "",
                            image: #imageLiteral(resourceName: "screen3"))
        ]
        
    }
    
//    override func style(cell: UICollectionViewCell, for page: Int) {
//        super.style(cell: cell, for: page)
//        guard let cell = cell as? OnboardingCell else { return }
////        cell.doneButton.isHidden = true
//
//    }
    
    override func visibilityChanged(for cell: UICollectionViewCell, at index: Int, amount: CGFloat) {
        guard let cell = cell as? OnboardingCell, index == pageCount - 1  else { return }
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
}
}
