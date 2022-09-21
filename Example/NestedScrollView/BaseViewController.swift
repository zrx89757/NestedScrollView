//
//  BaseViewController.swift
//  NestedScrollView
//
//  Created by vino on 2022/9/9.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
    }
    
    deinit {
        print(NSStringFromClass(self.classForCoder) + " deinit")
    }

}
