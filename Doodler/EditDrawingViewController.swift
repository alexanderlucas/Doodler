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
    
    var currentDrawing: Drawing!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action:#selector(handleScreenPan))

        drawingView.addGestureRecognizer(panGestureRecognizer)
        
        currentDrawing = Drawing()
        
    }
    
    @objc func handleScreenPan(_ sender: UIGestureRecognizer) {
        
        switch sender.state {
        case .began:
            let firstPoint = sender.location(in: self.drawingView)
            
            if segment.selectedSegmentIndex == 0 {
                let layer = currentDrawing.drawStarted(at: firstPoint)
                drawingView.layer.addSublayer(layer)
            } else {
                currentDrawing.eraseStarted(at: firstPoint)
            }
            
        case .changed:
            let point = sender.location(in: self.drawingView)

            if segment.selectedSegmentIndex == 0 {
                currentDrawing.drawMoved(to: point)
            } else {
                currentDrawing.eraseMoved(to: point)
            }

        case .ended:
        
            if segment.selectedSegmentIndex == 0 {
                currentDrawing.drawEnded()
            } else {
                currentDrawing.eraseEnded()
            }
            
        default: ()
        }
    }

    @IBAction func scaleButtonPressed(_ sender: Any) {
        var transform = CGAffineTransform.identity
        transform = transform.scaledBy(x:  0.5, y: 0.5)

        for mark in currentDrawing.marks {
            mark.drawingLayer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
        }
    }
    
}

