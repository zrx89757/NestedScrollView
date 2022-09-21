//
//  WebViewController.swift
//  NestedScrollView
//
//  Created by vino on 2022/9/19.
//

import UIKit
import WebKit
import NestedScrollView

class WebViewController: BaseViewController {
    
    private weak var currentScrollView: UIScrollView?
    
    var scrollCallBack: ((UIScrollView) -> Void)?
    
    lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.delegate = self
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        webView.navigationDelegate = self
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        currentScrollView = webView.scrollView
        
        webView.load(URLRequest(url: URL(string: "https://github.com/ReactiveX/RxSwift")!))
    }
}

extension WebViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCallBack?(scrollView)
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("加载成功")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("加载失败")
    }
}

extension WebViewController: ListViewDelegate {
    func listView() -> UIView {
        view
    }
    
    func listScrollView() -> UIScrollView {
        currentScrollView!
    }
    
    func listViewDidScroll(callBack: @escaping (UIScrollView) -> ()) {
        scrollCallBack = callBack
    }
}
