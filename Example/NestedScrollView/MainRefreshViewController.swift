//
//  MainRefreshViewController.swift
//  NestedScrollView
//
//  Created by vino on 2022/9/13.
//

import UIKit
import MJRefresh

class MainRefreshViewController: NormalListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Main refresh"
        
        pageScrollView.mainTableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                guard let self = self else { return }
                self.pageScrollView.mainTableView.mj_header?.endRefreshing()
                
                if let x = self.pageScrollView.loadedListMap[self.segmentedView.selectedIndex] {
                    x.reloadData?()
                }
            }
        })
    }

}
