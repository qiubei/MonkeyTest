//
//  ViewController.swift
//  QBFastlaneMonkeyTest
//
//  Created by Jarvis on 2016/11/2.
//  Copyright © 2016年 Hangzhou Enter Electronic Technology Co., Ltd. All rights reserved.
//

import UIKit
import SnapKit


class ViewController: UIViewController {

    let testButton1: UIButton = {
        let button = UIButton()
        button.setTitle("test1", for: .normal)
        
        return button
    }()
    
    
    let testButton2: UIButton = {
        let button = UIButton()
        button.setTitle("test2", for: .normal)
        
        return button
    }()
    
    let testButton3: UIButton = {
        let button = UIButton()
        button.setTitle("test3", for: .normal)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.setupViews()
    }

    
    private func setupViews() {
        self.view.addSubview(self.testButton1)
        self.view.addSubview(self.testButton2)
        self.view.addSubview(self.testButton3)
        
        self.testButton1.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(30)
            $0.bottom.equalTo(self.view.snp.centerY).offset(-60)
            $0.centerX.equalTo(self.view.snp.centerX)
        }
        
        self.testButton2.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(30)
            $0.centerY.equalTo(self.view.snp.centerY)
            $0.centerX.equalTo(self.view.snp.centerX)
        }
        
        self.testButton3.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(30)
            $0.top.equalTo(self.view.snp.centerY).offset(60)
            $0.centerX.equalTo(self.view.snp.centerX)
        }
        
        self.testButton1.addTarget(self, action: #selector(self.buttonTest1Action(button:)), for: .touchUpInside)
        self.testButton2.addTarget(self, action: #selector(self.buttontest2Action(button:)), for: .touchUpInside)
        self.testButton3.addTarget(self, action: #selector(self.buttontest3Action(button:)), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    func buttonTest1Action(button: UIButton) {
        print("test 1")
        
        let viewcontroller = UIViewController()
        viewcontroller.view.backgroundColor = UIColor.blue
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    func buttontest2Action(button: UIButton) {
        print("test 2")
        let viewcontroller = UIViewController()
        viewcontroller.view.backgroundColor = UIColor.yellow
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    func buttontest3Action(button: UIButton) {
        print("test 3")
        let viewcontroller = UIViewController()
        let button = UIButton()
        button.center = viewcontroller.view.center
        viewcontroller.view.addSubview(button)
        viewcontroller.view.backgroundColor = UIColor.green
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }

}

