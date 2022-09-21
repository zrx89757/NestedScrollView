//
//  GestureHandleTableView.swift
//  NestedScrollView
//
//  Created by vino on 2022/9/7.
//

import UIKit

@objc public protocol GestureHandleTableViewDelegate: NSObjectProtocol {
    
    @objc optional func mainTableView(_ tableView: GestureHandleTableView, gestureRecognizerShouldBegin gestureRecognizer: UIGestureRecognizer) -> Bool
    
    @objc optional func mainTableView(_ tableView: GestureHandleTableView, gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
}

public class GestureHandleTableView: UITableView {
    
    weak var gestureDelegate: GestureHandleTableViewDelegate?

    var horizontalScrollViews: [UIScrollView]?
}

extension GestureHandleTableView: UIGestureRecognizerDelegate {
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let result = self.gestureDelegate?.mainTableView?(self, gestureRecognizerShouldBegin: gestureRecognizer) {
            return result
        }
        
        if self.panBack(gestureRecognizer: gestureRecognizer) {
            return false
        }
        
        return true
    }
    
    func panBack(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.panGestureRecognizer {
            let point = self.panGestureRecognizer.translation(in: self)
            let state = gestureRecognizer.state

            let locationDistance = UIScreen.main.bounds.size.width

            if state == .began || state == .possible {
                let location = gestureRecognizer.location(in: self)
                if point.x > 0 && location.x < locationDistance && self.contentOffset.x <= 0 {
                    return true
                }
            }
        }
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let result = self.gestureDelegate?.mainTableView?(self, gestureRecognizer: gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) {
            return result
        }
        
        if let list = self.horizontalScrollViews {
            var exist = false
            for scrollView in list {
                if gestureRecognizer.view?.isEqual(scrollView) == true {
                    exist = true
                }
                if otherGestureRecognizer.view?.isEqual(scrollView) == true {
                    exist = true
                }
            }
            if exist { return false }
        }
        
        return gestureRecognizer.view?.isKind(of: UIScrollView.classForCoder()) ?? false && otherGestureRecognizer.view?.isKind(of: UIScrollView.classForCoder()) ?? false
    }
}
