//
//  ChangeHeaderViewController.swift
//  NestedScrollView
//
//  Created by vino on 2022/9/13.
//

import UIKit
import JXSegmentedView
import NestedScrollView

class XXHeader: UIView {
    enum Style {
        case one
        case two
    }
    
    var clickCallback: (() -> Void)?
    
    let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.textColor = .black
    }
    
    let iv = UIImageView().then {
        $0.backgroundColor = .red
    }
    
    let style: Style
    
    init(style: Style, frame: CGRect) {
        self.style = style
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func test() {
        clickCallback?()
    }
    
    func setupUI() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(100)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(26)
        }
        
        addSubview(iv)
        iv.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.size.equalTo(80)
        }
        
        switch style {
        case .one:
            backgroundColor = .lightGray
            
            titleLabel.text = "Style One"
            
            let button = UIButton(type: .detailDisclosure)
            addSubview(button)
            
            button.snp.makeConstraints { make in
                make.leading.equalTo(16)
                make.top.equalTo(iv.snp.bottom).offset(8)
                make.size.equalTo(CGSize(width: 60, height: 40))
            }
            
            button.addTarget(self, action: #selector(test), for: .touchUpInside)
            
        case .two:
            backgroundColor = .white
            
            titleLabel.text = "Style Two"
        }
    }
}

class ChangeHeaderViewController: BaseViewController {
    
    var titleDataSource = JXSegmentedTitleDataSource()
    
    lazy var pageScrollView: NestedScrollView = {
        let pageScrollView = NestedScrollView(delegate: self)
        pageScrollView.ceilPointHeight = 0
        return pageScrollView
    }()
    
    var titles: [String] {
        ["test1", "test2", "test3"]
    }
    
    var headerView = XXHeader(style: .one, frame: CGRect(x: 0, y: 0, width: screenWidth, height: 272))
    
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

        navigationItem.title = "Change Header Height"

        view.addSubview(pageScrollView)
        
        pageScrollView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
        }
        pageScrollView.reloadData()
        
        headerView.clickCallback = { [weak self] in
            guard let self = self else { return }
            self.headerView = XXHeader(style: .two, frame: CGRect(x: 0, y: 0, width: screenWidth, height: 223))
            self.pageScrollView.refreshHeaderView()
        }
    }
}

extension ChangeHeaderViewController: NestedScrollViewDelegate {
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
        let x = index == titles.count - 1 ? DemoListViewController(dataCount: 5) : DemoListViewController()
        self.addChildViewController(x)
        return x
    }
}

extension ChangeHeaderViewController: JXSegmentedViewDelegate {
    
}

