//
//  NestedScrollViewDelegate.swift
//  NestedScrollView
//
//  Created by vino on 2022/9/8.
//

import UIKit

@objc public protocol ListViewDelegate : NSObjectProtocol {
    /// 返回 listView 内部所持有的 scrollview
    func listScrollView() -> UIScrollView
    
    /// 当 listView 所持有的 scrollview 的代理方法`scrollViewDidScroll`回调时，需要调用该代理方法传入callBack
    func listViewDidScroll(callBack: @escaping (UIScrollView)->())
    
    /// 返回listView
    func listView() -> UIView
    
    /// 刷新数据源
    @objc optional func reloadData() -> Void
}

@objc public protocol NestedScrollViewDelegate : NSObjectProtocol {
    /// 返回tableHeaderView
    func headerView(in scrollView: NestedScrollView) -> UIView
    
    /// 返回中间的segmentedView
    func segmentedView(in scrollView: NestedScrollView) -> UIView
    
    func currentOnReadyListScrollView(in scrollView: NestedScrollView) -> UIScrollView?
    
    /// 返回列表的数量
    @objc optional func numberOfLists(in scrollView: NestedScrollView) -> Int
    
    /// 根据index初始化一个列表实例，需实现`ListViewDelegate`代理
    @objc optional func nestedScrollView(_ scrollView: NestedScrollView, initListAtIndex index: Int) -> ListViewDelegate
    
    // MARK: - 非懒加载相关方法

    /// 返回分页试图
    @objc optional func pageView(in scrollView: NestedScrollView) -> UIView
    
    /// 返回listView，需实现 ListViewDelegate 协议
    @objc optional func listView(in scrollView: NestedScrollView) -> [ListViewDelegate]
    
    // MARK: - mainTableView滚动相关方法
    
    /// mainTableView开始滑动回调
    @objc optional func mainTableViewWillBeginDragging(_ scrollView: UIScrollView)
    
    /// mainTableView滑动回调，可用于实现导航栏渐变、头图缩放等功能
    ///
    /// - Parameters:
    ///   - scrollView: mainTableView
    ///   - isMainCanScroll: mainTableView是否可滑动，YES表示可滑动，没有到达临界点，NO表示不可滑动，已到达临界点
    @objc optional func mainTableViewDidScroll(_ scrollView: UIScrollView, isMainCanScroll: Bool)
    
    /// mainTableView结束滑动回调
    ///
    /// - Parameters:
    ///   - scrollView: mainTableView
    ///   - willDecelerate: 是否将要减速
    @objc optional func mainTableViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate: Bool)
    
    /// mainTableView结束滑动回调
    ///
    /// - Parameter scrollView: mainTableView
    @objc optional func mainTableViewDidEndDecelerating(_ scrollView: UIScrollView)
    
    /// mainTableView结束滑动动画
    /// - Parameter scrollView: mainTableView
    @objc optional func mainTableViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
}

