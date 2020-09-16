//
//  ViewController.swift
//  Doodler
//
//  Created by Alex Lucas on 9/16/20.
//

import UIKit

class EditDrawingViewController: UIViewController {
    
    var drawingView: DrawingView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action:#selector(handleScreenPan))

        view.addGestureRecognizer(panGestureRecognizer)

        
        drawingView = DrawingView(frame: self.view.frame)
        self.view.addSubview(drawingView!)

    }
    
    @objc func handleScreenPan(_ sender: UIGestureRecognizer) {
        guard let drawingView = drawingView else {
            return
        }
        
        switch sender.state {
        case .began:
            let firstPoint = sender.location(in: self.view)
            
            drawingView.drawStarted(at: firstPoint)
            
        case .changed:
            let point = sender.location(in: self.view)

            drawingView.drawMoved(to: point)

        case .ended:
            drawingView.drawEnded()
        
            
        default: ()
        }
    }


}

