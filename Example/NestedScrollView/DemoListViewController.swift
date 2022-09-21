//
//  DemoListViewController.swift
//  NestedScrollView
//
//  Created by vino on 2022/9/9.
//

import UIKit
import MJRefresh
import NestedScrollView

class DemoListViewController: BaseViewController {
    
    var scrollCallBack: ((UIScrollView) -> ())?
    
    var mockCount: Int
    
    init(dataCount: Int = 30) {
        self.mockCount = dataCount
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tableView.reloadData()
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "tableViewCell")
        return tableView
    }()

    func addHeaderRefresh() {
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                guard let self = self else { return }
                self.tableView.mj_header?.endRefreshing()
                self.reloadData()
            })
        })
    }
}

extension DemoListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mockCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        cell.textLabel?.text = "第\(indexPath.row+1)行"
        return cell
    }
}

extension DemoListViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCallBack?(scrollView)
    }
}

extension DemoListViewController: ListViewDelegate {
    func listView() -> UIView {
        view
    }
    
    func listScrollView() -> UIScrollView {
        tableView
    }
    
    func listViewDidScroll(callBack: @escaping (UIScrollView) -> ()) {
        scrollCallBack = callBack
    }
    
    func reloadData() {
        mockCount += 5
        tableView.reloadData()
    }
}
