//
//  NestedScrollView.swift
//  NestedScrollView
//
//  Created by vino on 2022/9/7.
//

import UIKit
import SnapKit

public class NestedScrollView: UIView {
    public lazy var mainTableView: GestureHandleTableView = {
        let x = GestureHandleTableView(frame: .zero, style: .plain)
        x.separatorStyle = .none
        x.showsVerticalScrollIndicator = false
        x.showsHorizontalScrollIndicator = false
        x.delegate = self
        x.dataSource = self
        x.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        if #available(iOS 11.0, *) {
            x.contentInsetAdjustmentBehavior = .never
        }
        if #available(iOS 15.0, *) {
            x.setValue(0, forKey: "sectionHeaderTopPadding")
        }
        return x
    }()
    
    public lazy var listContainer: ListContainer = {
        let x = ListContainer(delegate: self)
        return x
    }()
    
    // 是否开始拖拽，只有在拖拽中才去处理滑动，解决使用mj_header可能出现的bug
    var isBeginDragging: Bool = false
    
    var previousContentOffsetY: CGFloat = 0
    
    // 是否需要将主列表的滑动动量传递给子列表
    var shouldPassThrough = false
    
    // 包裹 segmentedView 和列表容器的 view
    public var pageView: UIView?
    
    weak var delegate: NestedScrollViewDelegate!
    
    var headerHeight: CGFloat = 0
    
    var isRefreshHeader = false
    
    // 是否加载
    var isLoaded: Bool = false
    
    // 是否滑动到临界点，可以有偏差
    public var isCriticalPoint = false
    // 是否达到临界点，无偏差
    public var isCeilPoint = false
    
    // 刷新 headerView 后是否恢复到原始状态
    public var isRestoreWhenRefreshHeader = false
    
    // 吸顶临界点高度（默认：状态栏+导航栏）
    public var ceilPointHeight: CGFloat = navBarHeight
    
    // 临界点
    var criticalPoint: CGFloat = 0
    var criticalOffset: CGPoint = .zero
    
    // 当前已经加载过可用的列表字典，key是index值，value是对应的列表
    public var loadedListMap = [Int: ListViewDelegate]()
    
    // 当前滑动的子列表
    public var currentListScrollView = UIScrollView()
    
    // 是否允许列表下拉刷新，默认为 flase
    public var isAllowListRefresh = false
    
    // 是否禁止主页滑动，默认NO
    public var isMainScrollDisabled = false {
        didSet {
            mainTableView.isScrollEnabled = !isMainScrollDisabled
            if isMainScrollDisabled {
                mainTableView.scrollsToTop = false
            }
        }
    }
    
    // 是否禁止 mainScrollView 在到达临界点后继续滑动，默认为 false
    public var isDisableMainScrollInCeil = false

    // mainTableView 是否可以滑动
    public var isMainCanScroll = true
    // listScrollView 是否可以滑动
    public var isListCanScroll = false
    
    // 快速切换原点和临界点
    var isScrollToOriginal = false
    var isScrollToCritical = false
    
    public init(delegate: NestedScrollViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        setupUI()
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupUI() {
        addSubview(mainTableView)
        mainTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        refreshHeaderView()
        
        mainTableView.horizontalScrollViews = [listContainer.collectionView]
    }
    
    public func reloadData() {
        isLoaded = true
        for list in loadedListMap.values {
            list.listView().removeFromSuperview()
        }
        loadedListMap.removeAll()
        
        listContainer.reloadData()
        
        mainTableView.reloadData()
        
        criticalPoint = abs(mainTableView.rect(forSection: 0).origin.y - ceilPointHeight)
        print("criticalPoint: \(criticalPoint)")
        criticalOffset = CGPoint(x: 0, y: criticalPoint)
    }
    
    public func appendHorizontalScrollViews(_ views: [UIScrollView]) {
        var x = mainTableView.horizontalScrollViews ?? [UIScrollView]()
        x.append(contentsOf: views)
        mainTableView.horizontalScrollViews = x
    }
    
    public func refreshHeaderView() {
        let headerView = delegate.headerView(in: self)
        mainTableView.tableHeaderView = headerView
        headerHeight = headerView.frame.size.height
        
        criticalPoint = abs(mainTableView.rect(forSection: 0).origin.y - ceilPointHeight)
        criticalOffset = CGPoint(x: 0, y: criticalPoint)
        
        if isRestoreWhenRefreshHeader {
            scrollToOriginalPoint(false)
        } else {
            if isCriticalPoint {
                isRefreshHeader = true
                scrollToCriticalPoint(false)
            }
        }
    }
    
    public func horizonScrollViewWillBeginScroll() {
        mainTableView.isScrollEnabled = false
    }
    
    public func horizonScrollViewDidEndedScroll() {
        mainTableView.isScrollEnabled = true
    }
    
    public func scrollToOriginalPoint(_ animated: Bool = true) {
        // 这里做了0.01秒的延时，是为了解决一个坑：
        // 当通过手势滑动结束调用此方法时，会有可能出现动画结束后UITableView没有回到原点的bug
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if self.mainTableView.contentOffset == .zero { return }
            if self.isScrollToOriginal { return }
            
            if animated == true {
                self.isScrollToOriginal = true
            }
            self.isCeilPoint = false
            
            if self.isScrollToCritical {
                self.isScrollToCritical = false;
            }
            
            self.isMainCanScroll = true
            self.isListCanScroll = false
            
            self.mainTableView.setContentOffset(.zero, animated: animated)
        }
    }
    
    public func scrollToCriticalPoint(_ animated: Bool = true) {
        if mainTableView.contentOffset == criticalOffset { return }
        if isScrollToCritical { return }
        
        if animated {
            isScrollToCritical = true
        } else {
            isCeilPoint = true
        }
        
        if isScrollToOriginal {
            isScrollToOriginal = false
        }
        
        mainTableView.setContentOffset(criticalOffset, animated: animated)
        
        isMainCanScroll = false
        isListCanScroll = true
        
        mainTableViewCanScrollUpdate()
    }
    
    public func listScrollViewDidScroll(scrollView: UIScrollView) {
        currentListScrollView = scrollView
        
        if isMainScrollDisabled { return }
        
        if isScrollToOriginal || isScrollToCritical { return }
        
        let offsetY = scrollView.contentOffset.y
        
        // listScrollView 下滑至 offsetY 小于0，禁止其滑动，让 mainTableView 可下滑
        if offsetY <= 0 {
            if isDisableMainScrollInCeil {
                if isAllowListRefresh && offsetY < 0 && isCeilPoint {
                    isMainCanScroll = false
                    isListCanScroll = true
                } else {
                    isMainCanScroll = true
                    isListCanScroll = false
                    set(scrollView: scrollView, offset: .zero)
                }
            } else {
                if isAllowListRefresh && offsetY < 0 && mainTableView.contentOffset.y == 0 {
                    isMainCanScroll = false
                    isListCanScroll = true
                } else {
                    isMainCanScroll = true
                    isListCanScroll = false
                    set(scrollView: scrollView, offset: .zero)
                }
            }
        } else {
            if isListCanScroll {
                let headerHeight = self.headerHeight
                
                if floor(headerHeight) == 0 {
                    set(scrollView: mainTableView, offset: criticalOffset)
                } else {
                    // 如果此时 mainTableView 并没有滑动，则禁止 listView 滑动
                    if mainTableView.contentOffset.y == 0 && floor(headerHeight) != 0 {
                        isMainCanScroll = true
                        isListCanScroll = false
                        
                        set(scrollView: scrollView, offset: .zero)
                    } else { // 矫正 mainTableView 的位置
                        set(scrollView: mainTableView, offset: criticalOffset)
                    }
                }
            } else {
                set(scrollView: scrollView, offset: .zero)
            }
        }
    }
    
    public func mainScrollViewDidScroll(scrollView: UIScrollView) {
        guard isBeginDragging else {
            if isRefreshHeader {
                isRefreshHeader = false
            } else {
                listScrollViewOffsetFixed()
            }
            mainTableViewCanScrollUpdate()
            return
        }
        
        // 获取mainScrollView偏移量
        let offsetY = scrollView.contentOffset.y
        
        if isScrollToOriginal || isScrollToCritical { return }
        
        // 无偏差临界点，对float值取整判断
        if !isCeilPoint {
            isCeilPoint = floor(offsetY) == floor(criticalPoint)
        }
        
        // 根据偏移量判断是否上滑到临界点
        isCriticalPoint = offsetY >= criticalPoint
        
        if isCriticalPoint {
            if shouldPassThrough {
                guard let x = delegate.currentOnReadyListScrollView(in: self) else {
                    return
                }
                
                let padding = offsetY - criticalPoint + 2
                print("padding: \(padding)")
                var offset = x.contentOffset
                offset.y += padding
                let max = x.contentSize.height - x.bounds.height
                if offset.y > max {
                    offset.y = max
                }
                x.contentOffset = offset
            }

            // 上滑到临界点后，固定其位置
            isMainCanScroll = false
            isListCanScroll = true
            
            set(scrollView: scrollView, offset: criticalOffset)
        } else {
            // 当滑动到无偏差临界点且不允许 mainScrollView 滑动时做处理
            if isCeilPoint && isDisableMainScrollInCeil {
                isMainCanScroll = false
                isListCanScroll = true
                set(scrollView: scrollView, offset: criticalOffset)
            } else {
                if isDisableMainScrollInCeil {
                    if isMainCanScroll {
                        // 未达到临界点，mainTableView可滑动，需要重置所有listScrollView的位置
                        listScrollViewOffsetFixed()
                    } else {
                        // 未到达临界点，mainScrollView不可滑动，固定mainScrollView的位置
                        mainScrollViewOffsetFixed()
                    }
                } else {
                    // 如果允许列表刷新，且mainTableView的offsetY小于0 或者 当前列表的offsetY小于0，mainTableView不可滑动
                    if isAllowListRefresh && ((offsetY <= 0 && isMainCanScroll) || (currentListScrollView.contentOffset.y < 0 && isListCanScroll)) {
                        set(scrollView: scrollView, offset: .zero)
                    } else {
                        if isMainCanScroll {
                            // 未达到临界点，mainTableView可滑动，需要重置所有listScrollView的位置
                            listScrollViewOffsetFixed()
                        } else {
                            // 未到达临界点，mainScrollView不可滑动，固定mainScrollView的位置
                            mainScrollViewOffsetFixed()
                        }
                    }
                }
            }
        }
        mainTableViewCanScrollUpdate()
    }
}

extension NestedScrollView {
    fileprivate func set(scrollView: UIScrollView, offset: CGPoint) {
        if !__CGPointEqualToPoint(scrollView.contentOffset, offset) {
            scrollView.contentOffset = offset
        }
    }
    
    fileprivate func getPageView() -> UIView {
        let width = frame.size.width == 0 ? screenWidth : frame.size.width
        var height = frame.size.height == 0 ? screenHeight : frame.size.height
        
        var pageView = self.pageView
        
        if let x = delegate.pageView?(in: self) {
            pageView = x
        } else {
            if (pageView == nil) {
                pageView = UIView()
            }
            let segmentedView = delegate.segmentedView(in: self)
            
            let x: CGFloat = 0
            let y: CGFloat = segmentedView.frame.size.height
            let w: CGFloat = width
            var h: CGFloat = height - y
            h -= (isMainScrollDisabled ? headerHeight : ceilPointHeight)

            listContainer.frame = CGRect(x: x, y: y, width: w, height: h)
            pageView?.addSubview(segmentedView)
            pageView?.addSubview(listContainer)
        }
        
        height -= (isMainScrollDisabled ? self.headerHeight : ceilPointHeight)
        pageView?.frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.pageView = pageView
        return pageView!
    }
    
    fileprivate func listScrollViewOffsetFixed() {
        if let listViews = delegate.listView?(in: self) {
            listViews.forEach {
                let scrollView = $0.listScrollView()
                set(scrollView: scrollView, offset: .zero)
            }
        } else {
            loadedListMap.forEach {
                let scrollView = $0.value.listScrollView()
                set(scrollView: scrollView, offset: .zero)
            }
        }
    }
    
    // 修正mainTableView的位置
    fileprivate func mainScrollViewOffsetFixed() {
        set(scrollView: mainTableView, offset: criticalOffset)
    }
    
    fileprivate func mainTableViewCanScrollUpdate() {
        delegate.mainTableViewDidScroll?(mainTableView, isMainCanScroll: isMainCanScroll)
    }
}

extension NestedScrollView: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isLoaded ? 1 : 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
        cell.contentView.addSubview(getPageView())
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = frame.size.height == 0 ? screenHeight : frame.size.height
        height -= (isMainScrollDisabled ? headerHeight : ceilPointHeight)
        return height
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("main table scroll: \(scrollView.contentOffset.y)")
        
        mainScrollViewDidScroll(scrollView: scrollView)
        
        previousContentOffsetY = scrollView.contentOffset.y
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isBeginDragging = true
        if isScrollToOriginal {
            isScrollToOriginal = false
            isCeilPoint = false
        }
        
        if isScrollToCritical {
            isScrollToCritical = false
            isCeilPoint = true
        }
        
        delegate.mainTableViewWillBeginDragging?(scrollView)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetOffsetY = targetContentOffset.pointee.y
        print("should pass through target offset y: \(targetOffsetY)")
        // 必须是手势往上，列表内容往下滚动，加载更多的时候，且可能滑动超过临界点时才需要传递滚动动量
        shouldPassThrough = targetOffsetY > previousContentOffsetY && targetOffsetY >= criticalPoint
        print("should pass through: \(shouldPassThrough)")
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            isBeginDragging = false
        }
        delegate.mainTableViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isBeginDragging = false
        delegate.mainTableViewDidEndDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        delegate.mainTableViewDidEndScrollingAnimation?(scrollView)
        
        if isScrollToOriginal {
            isScrollToOriginal = false
            isCeilPoint = false
            
            // 修正listView偏移
            listScrollViewOffsetFixed()
        }
        
        if isScrollToCritical {
            isScrollToCritical = false
            isCeilPoint = true
        }
        
        mainTableViewCanScrollUpdate()
    }

}

extension NestedScrollView: ListContainerDelegate {
    public func numberOfRows(in container: ListContainer) -> Int {
        delegate.numberOfLists?(in: self) ?? 0
    }
    
    public func listContainerView(_ container: ListContainer, viewForListInRow row: Int) -> UIView {
        var list = loadedListMap[row]
        if list == nil {
            list = delegate.nestedScrollView?(self, initListAtIndex: row)
            list?.listViewDidScroll(callBack: { [weak self] scrollView in
                self?.listScrollViewDidScroll(scrollView: scrollView)
            })
            loadedListMap[row] = list!
        }
        return list!.listView()
    }
    
    public func listScrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        mainTableView.isScrollEnabled = false
    }
    
    public func listScrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        mainTableView.isScrollEnabled = true
    }
    
    public func listScrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            mainTableView.isScrollEnabled = true
        }
    }
}
