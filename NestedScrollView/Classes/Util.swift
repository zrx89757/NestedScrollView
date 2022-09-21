//
//  Util.swift
//  NestedScrollView
//
//  Created by vino on 2022/9/7.
//

import UIKit

// 状态栏高度
public let statusBarHeight: CGFloat = Util.statusBarFrame().size.height

// 导航栏+状态栏高度
public let navBarHeight: CGFloat = (statusBarHeight + 44.0)

// 屏幕宽高
public let screenWidth = UIScreen.main.bounds.size.width
public let screenHeight = UIScreen.main.bounds.size.height

public enum Util {
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
