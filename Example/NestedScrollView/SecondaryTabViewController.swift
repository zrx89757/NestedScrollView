//
//  SecondaryTabViewController.swift
//  NestedScrollView
//
//  Created by vino on 2022/9/15.
//

import UIKit
import JXSegmentedView
import NestedScrollView

class SecondaryTabViewController: NormalListViewController {
    
    override var titles: [String] {
        ["Test1", "Test2", "Test3", "Test4"]
    }
    
    var nestView = NestedView()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "二级标签嵌套"
    }
}

extension SecondaryTabViewController {
    override func nestedScrollView(_ scrollView: NestedScrollView, initListAtIndex index: Int) -> ListViewDelegate {
        let n = NestedView()
        n.delegate = self
        return n
    }
}

extension SecondaryTabViewController {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        nestView = pageScrollView.loadedListMap[index] as! NestedView
    }
}

extension SecondaryTabViewController: NestedViewDelegate {
    func nestedViewWillScroll() {
        pageScrollView.horizonScrollViewWillBeginScroll()
    }
    
    func nestedViewEndScroll() {
        pageScrollView.horizonScrollViewDidEndedScroll()
    }
}

extension SecondaryTabViewController: GestureHandleCollectionViewDelegate {
    func collectionView(_ collectionView: GestureHandleCollectionView, gestureRecognizerShouldBegin gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if panBack(scrollView: collectionView, gestureRecognizer: gestureRecognizer) {
            return false
        }
        
        let listScrollView = nestView.contentScrollView
        
        if listScrollView.isTracking || listScrollView.isDragging {
            if gestureRecognizer.isMember(of: NSClassFromString("UIScrollViewPanGestureRecognizer")!) {
                let panGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
                
                let velocityX = panGestureRecognizer.velocity(in: gestureRecognizer.view).x
                
                if velocityX > 0 {
                    if listScrollView.contentOffset.x != 0 {
                        return false
                    }
                } else if velocityX < 0 {
                    if listScrollView.contentOffset.x + listScrollView.bounds.size.width != listScrollView.contentSize.width {
                        return false
                    }
                }
            }
        }
        
        return true
    }
    
    func collectionView(_ collectionView: GestureHandleCollectionView, gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        false
    }
    
    func panBack(scrollView: UIScrollView, gestureRecognizer: UIGestureRecognizer) -> Bool{
        if gestureRecognizer == scrollView.panGestureRecognizer {
            let point = scrollView.panGestureRecognizer.translation(in: scrollView)
            let state = gestureRecognizer.state

            let locationDistance = UIScreen.main.bounds.size.width

            if state == .began || state == .possible {
                let location = gestureRecognizer.location(in: scrollView)
                if point.x > 0 && location.x < locationDistance && scrollView.contentOffset.x <= 0 {
                    return true
                }
            }
        }
        return false
    }
}
