//
//  TestWindowView.swift
//  testDemo
//
//  Created by Ray on 2023/3/2.
//

import UIKit

class TestWindowView: UIView {
    lazy var rootNav: UINavigationController = {
        let nav = UINavigationController.init(rootViewController: FirstViewController())
        return nav
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        initCommon()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initCommon()
    }
    
    func initCommon() {
        self.addSubview(self.rootNav.view)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.rootNav.view.frame = self.bounds
        
    }
}
