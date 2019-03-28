//
//  ViewController.swift
//  BottomMenuAnimatedExample
//
//  Created by Pablo Barcos on 28/03/2019.
//  Copyright © 2019 Pablo Barcos. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var botomMenu: BottomMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createMenu()
    }

    func createMenu()  {
        botomMenu = BottomMenu(view: self.view)
        botomMenu!.layout()
    }
}

