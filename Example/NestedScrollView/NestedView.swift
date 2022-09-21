//
//  NestedView.swift
//  NestedScrollView
//
//  Created by vino on 2022/9/16.
//

import UIKit
import JXSegmentedView
import NestedScrollView

protocol NestedViewDelegate: AnyObject {
    func nestedViewWillScroll()
    func nestedViewEndScroll()
}

class NestedView: UIView {
    public weak var delegate: NestedViewDelegate?
    
    var titleDataSource = JXSegmentedTitleDataSource()
    
    var listScrollCallBack: ((UIScrollView) -> Void)?
    
    var currentListScrollView: UIScrollView = UIScrollView()

    lazy var segmentedView: JXSegmentedView = {
        titleDataSource.titleNormalColor = UIColor.gray
        titleDataSource.titleSelectedColor = UIColor.gray
        titleDataSource.titleNormalFont = UIFont.systemFont(ofSize: 14.0)
        titleDataSource.titleSelectedFont = UIFont.systemFont(ofSize: 14.0)
        titleDataSource.titles = ["sub1", "sub2", "sub3"]
        
        var segmentedView = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 40))
        segmentedView.delegate = self
        segmentedView.dataSource = titleDataSource
        segmentedView.backgroundColor = UIColor.white
        
        let lineView = JXSegmentedIndicatorLineView()
        lineView.lineStyle = .lengthen
        segmentedView.indicators = [lineView]
        
        segmentedView.contentScrollView = self.contentScrollView
        
        return segmentedView
    }()
    
    lazy var contentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.delegate = self
        
        scrollView.addSubview(list1)
        scrollView.addSubview(list2)
        scrollView.addSubview(list3)
        
        return scrollView
    }()
    
    lazy var list1: NestedListView = {
        let complistView = NestedListView()
        complistView.scrollCallBack = { [weak self] scrollView in
            self?.listScrollCallBack?(scrollView)
        }
        return complistView
    }()
    
    lazy var list2: NestedListView = {
        let saleListView = NestedListView()
        saleListView.scrollCallBack = { [weak self] scrollView in
            self?.listScrollCallBack!(scrollView)
        }
        return saleListView
    }()
    
    lazy var list3: NestedListView = {
        let priceListView = NestedListView()
        priceListView.scrollCallBack = { [weak self] scrollView in
            self?.listScrollCallBack!(scrollView)
        }
        return priceListView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(segmentedView)
        self.addSubview(contentScrollView)
        
        segmentedView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(40.0)
        }
        
        contentScrollView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(self)
            make.top.equalTo(segmentedView.snp.bottom)
        }
        currentListScrollView = list1.tableView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let listW = contentScrollView.frame.size.width
        let listH = contentScrollView.frame.size.height
        
        list1.frame = CGRect(x: 0, y: 0, width: listW, height: listH)
        list2.frame = CGRect(x: listW, y: 0, width: listW, height: listH)
        list3.frame = CGRect(x: 2 * listW, y: 0, width: listW, height: listH)
        
        contentScrollView.contentSize = CGSize(width: 3 * listW, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NestedView: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        switch index {
        case 0:
            currentListScrollView = list1.tableView
            break
        case 1:
            currentListScrollView = list2.tableView
            break
        case 2:
            currentListScrollView = list3.tableView
            break
        default:
            break
        }
    }
}

extension NestedView: ListViewDelegate {
    func listView() -> UIView {
        return self
    }
    
    func listScrollView() -> UIScrollView {
        return currentListScrollView
    }
    
    func listViewDidScroll(callBack: @escaping (UIScrollView) -> ()) {
        listScrollCallBack = callBack
    }
}

extension NestedView: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.nestedViewWillScroll()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            delegate?.nestedViewEndScroll()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.nestedViewEndScroll()
    }
}
