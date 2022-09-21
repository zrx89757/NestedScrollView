//
//  SubRefreshViewController.swift
//  NestedScrollView
//
//  Created by vino on 2022/9/13.
//

import UIKit
import NestedScrollView

class SubRefreshViewController: NormalListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Sub refresh"
        
        headerView.backgroundColor = .blue
        
        pageScrollView.isAllowListRefresh = true
    }
}

extension SubRefreshViewController {
    override func nestedScrollView(_ scrollView: NestedScrollView, initListAtIndex index: Int) -> ListViewDelegate {
        let x = DemoListViewController()
        self.addChildViewController(x)
        x.addHeaderRefresh()
        return x
    }
}
