//
//  GestureHandleCollectionView.swift
//  NestedScrollView
//
//  Created by vino on 2022/9/8.
//

import UIKit

@objc public protocol GestureHandleCollectionViewDelegate: NSObjectProtocol {
    
    @objc optional func collectionView(_ collectionView: GestureHandleCollectionView, gestureRecognizerShouldBegin gestureRecognizer: UIGestureRecognizer) -> Bool
    
    @objc optional func collectionView(_ collectionView: GestureHandleCollectionView, gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
}

public class GestureHandleCollectionView: UICollectionView, UIGestureRecognizerDelegate {
    public var isNestEnabled = false
    
    public weak var gestureDelegate: GestureHandleCollectionViewDelegate?
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let result = self.gestureDelegate?.collectionView?(self, gestureRecognizerShouldBegin: gestureRecognizer) {
            return result
        } else {
            if isNestEnabled {
                //没有代理，但是isNestEnabled为true
                if gestureRecognizer.isMember(of: NSClassFromString("UIScrollViewPanGestureRecognizer")!) {
                    let panGesture = gestureRecognizer as! UIPanGestureRecognizer
                    let velocityX = panGesture.velocity(in: panGesture.view!).x
                    // 处理超出边界条件时的情况
                    if velocityX > 0 { // 右滑
                        if self.contentOffset.x == 0 {
                            return false
                        }
                    } else if velocityX < 0 { // 左滑
                        if self.contentOffset.x + self.bounds.size.width == self.contentSize.width {
                            return false
                        }
                    }
                }
                return true
            }
        }
        
        if self.panBack(gestureRecognizer: gestureRecognizer) {
            return false
        }
        
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let result = self.gestureDelegate?.collectionView?(self, gestureRecognizer: gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) {
            return result
        }

        if self.panBack(gestureRecognizer: gestureRecognizer) {
            return true
        }
        
        return false
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
}

@objc public protocol ListContainerDelegate: NSObjectProtocol {
    func numberOfRows(in container: ListContainer) -> Int
    
    func listContainerView(_ container: ListContainer, viewForListInRow row: Int) -> UIView
    
    @objc optional func listScrollViewWillBeginDragging(_ scrollView: UIScrollView)
    
    @objc optional func listScrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    
    @objc optional func listScrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
}

public class ListContainer: UIView {
    public lazy var collectionView: GestureHandleCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let x = GestureHandleCollectionView(frame: .zero, collectionViewLayout: layout)
        x.showsVerticalScrollIndicator = false
        x.showsHorizontalScrollIndicator = false
        x.isPagingEnabled = true
        x.scrollsToTop = false
        x.bounces = false
        x.dataSource = self
        x.delegate = self
        x.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "cell")
        if #available(iOS 10.0, *) {
            x.isPrefetchingEnabled = false
        }
        if #available(iOS 11.0, *) {
            x.contentInsetAdjustmentBehavior = .never
        }
        return x
    }()
    
    public weak var delegate: ListContainerDelegate?
    
    public init(delegate: ListContainerDelegate) {
        self.delegate = delegate
        
        super.init(frame: .zero)
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func reloadData() {
        self.collectionView.reloadData()
    }
}

extension ListContainer: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.delegate!.numberOfRows(in: self)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
        let listView = self.delegate!.listContainerView(self, viewForListInRow: indexPath.item)
        listView.frame = cell.bounds
        cell.contentView.addSubview(listView)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        false
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.delegate?.listScrollViewWillBeginDragging?(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.delegate?.listScrollViewDidEndDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.delegate?.listScrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
}

extension ListContainer: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        bounds.size
    }
}
