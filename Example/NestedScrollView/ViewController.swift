//
//  ViewController.swift
//  NestedScrollView
//
//  Created by zrx89757 on 09/07/2022.
//  Copyright (c) 2022 zrx89757. All rights reserved.
//

import UIKit

public enum CommonTool {
    static func isNotchedScreen() -> Bool {
        if #available(iOS 11.0, *) {
            var window = getKeyWindow()
            if window == nil {
                // keyWindow还没有创建，通过创建临时window获取安全区域
                window = UIWindow(frame: UIScreen.main.bounds)
                if window!.safeAreaInsets.bottom <= 0 {
                    let viewController = UIViewController()
                    window?.rootViewController = viewController
                }
            }
            
            if window!.safeAreaInsets.bottom > 0 {
                return true
            }
        }
        return false
    }
    
    static func statusBarFrame() -> CGRect {
        var statusBarFrame = CGRect.zero
        if #available(iOS 13.0, *) {
            statusBarFrame = getKeyWindow()?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
        }
        
        if statusBarFrame == .zero {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        
        if statusBarFrame == .zero {
            let statusBarH: CGFloat = isNotchedScreen() ? 44.0 : 20.0
            statusBarFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: statusBarH)
        }
        return statusBarFrame
    }
    
    static func getKeyWindow() -> UIWindow? {
        var window: UIWindow?
        if #available(iOS 13.0, *) {
            window = UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .map { $0 as? UIWindowScene }
                .compactMap { $0 }
                .first?.windows
                .filter({ $0.isKeyWindow }).first
        }
        
        if window == nil {
            window = UIApplication.shared.windows.first { $0.isKeyWindow }
            if window == nil {
                window = UIApplication.shared.keyWindow
            }
        }
        return window
    }
}


// 状态栏高度
public let statusBarHeight: CGFloat = CommonTool.statusBarFrame().size.height

// 导航栏+状态栏高度
public let navBarHeight: CGFloat = (statusBarHeight + 44.0)

// 屏幕宽高
public let screenWidth = UIScreen.main.bounds.size.width
public let screenHeight = UIScreen.main.bounds.size.height

class ViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    let dataSource = [["group": "NestedScrollViewDemo", "list": [
        ["title": "测试系统侧滑返回", "class": "TestViewController"],
        ["title": "基础嵌套加载", "class": "NormalListViewController"],
        ["title": "主列表刷新", "class": "MainRefreshViewController"],
        ["title": "子列表刷新", "class": "SubRefreshViewController"],
        ["title": "二级标签", "class": "SecondaryTabViewController"],
        ["title": "修改header高度", "class": "ChangeHeaderViewController"]
    ]]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Demo"
        
        view.addSubview(self.tableView)
        
        tableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(navBarHeight)
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let list = self.dataSource[section]["list"] as! [Any]
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        let list = self.dataSource[indexPath.section]["list"] as! [Any]
        let dict = list[indexPath.row] as! [String: String]
        cell.textLabel?.text = dict["title"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let projectName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        
        let list = self.dataSource[indexPath.section]["list"] as! [Any]
        let dict = list[indexPath.row] as! [String: String]
        let className = dict["class"]
        
        let vc = (NSClassFromString(projectName + "." + className!) as! UIViewController.Type).init()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }

}


