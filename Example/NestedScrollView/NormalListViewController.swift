//
//  NormalListViewController.swift
//  NestedScrollView
//
//  Created by vino on 2022/9/9.
//

import UIKit
import JXSegmentedView
import NestedScrollView

class NormalListViewController: BaseViewController {
    
    var titleDataSource = JXSegmentedTitleDataSource()
    
    lazy var pageScrollView: NestedScrollView = {
        let pageScrollView = NestedScrollView(delegate: self)
        pageScrollView.ceilPointHeight = 0
        return pageScrollView
    }()
    
    lazy var headerView = ComplexHeader(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 586))
    
    var titles: [String] {
        ["test1", "test2", "test3", "test4"]
    }
    
    lazy var segmentedView: JXSegmentedView = {
        titleDataSource.titles = self.titles
        titleDataSource.titleNormalColor = UIColor.gray
        titleDataSource.titleSelectedColor = UIColor.red
        titleDataSource.titleNormalFont = UIFont.systemFont(ofSize: 15.0)
        titleDataSource.titleSelectedFont = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleDataSource.reloadData(selectedIndex: 0)
        
        var segmentedView = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 40))
        segmentedView.delegate = self
        segmentedView.dataSource = titleDataSource
        
        let lineView = JXSegmentedIndicatorLineView()
        lineView.lineStyle = .normal
        lineView.indicatorHeight = 4.0
        lineView.verticalOffset = 2.0
        segmentedView.indicators = [lineView]
        
        segmentedView.contentScrollView = self.pageScrollView.listContainer.collectionView
        
        let btmLineView = UIView()
        btmLineView.backgroundColor = .darkGray
        segmentedView.addSubview(btmLineView)
        btmLineView.snp.makeConstraints({ (make) in
            make.left.right.bottom.equalTo(segmentedView)
            make.height.equalTo(2.0)
        })
        
        return segmentedView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Normal List"

        view.addSubview(pageScrollView)
        
        pageScrollView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
//            make.edges.equalToSuperview()
        }
        pageScrollView.reloadData()
        
        // 添加横向滚动的 scrollView，避免在横向滚动的同时触发主列表竖向滚动
        pageScrollView.appendHorizontalScrollViews([headerView.hCollectionView])
    }

}

extension NormalListViewController: NestedScrollViewDelegate {
    func headerView(in scrollView: NestedScrollView) -> UIView {
        headerView
    }
    
    func segmentedView(in scrollView: NestedScrollView) -> UIView {
        segmentedView
    }
    
    func numberOfLists(in scrollView: NestedScrollView) -> Int {
        titles.count
    }
    
    func currentOnReadyListScrollView(in scrollView: NestedScrollView) -> UIScrollView? {
        let index = segmentedView.selectedIndex
        return pageScrollView.loadedListMap[index]?.listScrollView()
    }
    
    func nestedScrollView(_ scrollView: NestedScrollView, initListAtIndex index: Int) -> ListViewDelegate {
        if index < 2 {
            let x = DemoListViewController()
            self.addChildViewController(x)
            return x
        } else if index == 2 {
            let x = DemoListViewController(dataCount: 5)
            self.addChildViewController(x)
            return x
        } else {
            let x = WebViewController()
            self.addChildViewController(x)
            return x
        }
    }
}

extension NormalListViewController: JXSegmentedViewDelegate {
    
}
