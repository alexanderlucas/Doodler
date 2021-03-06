//
//  ViewController.swift
//  Doodler
//
//  Created by Alex Lucas on 9/16/20.
//

import UIKit

class EditDrawingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action:#selector(handleScreenPan))

        view.addGestureRecognizer(panGestureRecognizer)

    }
    
    @objc func handleScreenPan(_ sender: UIGestureRecognizer) {
        switch sender.state {
        case .began:
            let firstPoint = sender.location(in: self.view)
            //get first point
        case .changed:
            let destPoint = sender.location(in: self.view)
        case .ended:()
            
            
            
        default: ()
        }
    }


}

