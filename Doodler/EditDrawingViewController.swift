//
//  ViewController.swift
//  Doodler
//
//  Created by Alex Lucas on 9/16/20.
//

import UIKit

class EditDrawingViewController: UIViewController {
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var drawingView: DrawingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action:#selector(handleScreenPan))

        drawingView.addGestureRecognizer(panGestureRecognizer)
        
    }
    
    @objc func handleScreenPan(_ sender: UIGestureRecognizer) {
        
        switch sender.state {
        case .began:
            let firstPoint = sender.location(in: self.drawingView)
            
            if segment.selectedSegmentIndex == 0 {
                drawingView.drawStarted(at: firstPoint)
            } else {
                drawingView.eraseStarted(at: firstPoint)
            }
            
        case .changed:
            let point = sender.location(in: self.drawingView)

            if segment.selectedSegmentIndex == 0 {
                drawingView.drawMoved(to: point)
            } else {
                drawingView.eraseMoved(to: point)
            }

        case .ended:
        
            if segment.selectedSegmentIndex == 0 {
                drawingView.drawEnded()
            } else {
                drawingView.eraseEnded()
            }
            
        default: ()
        }
    }


}

