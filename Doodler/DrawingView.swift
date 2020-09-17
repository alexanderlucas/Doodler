//
//  DrawingView.swift
//  Doodler
//
//  Created by Alex Lucas on 9/16/20.
//

import UIKit

class DrawingView: UIView {
    
    var layers = [CAShapeLayer]()
    
    let path = UIBezierPath()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        

    }
    
    func drawStarted(at point: CGPoint) {
        let drawingLayer = CAShapeLayer()
        
        drawingLayer.fillColor = nil
        drawingLayer.strokeColor = UIColor.label.cgColor
        let thickness = Int.random(in: 0..<10)
        drawingLayer.lineWidth = CGFloat(thickness)

        layer.addSublayer(drawingLayer)
        layers.append(drawingLayer)

        path.move(to: point)
        
    }
    
    func drawMoved(to point: CGPoint) {
        guard let drawingLayer = layers.last else {
            return
        }
        path.addLine(to: point)
        drawingLayer.path = path.cgPath
    }
    
    func drawEnded() {
        path.removeAllPoints()
    }
    
    func eraseStarted(at point: CGPoint) {
        for (i, l) in layers.enumerated() {
            if l.path!.contains(point) {
                l.removeFromSuperlayer()
                layers.remove(at: i)
            }
        }
    }
    
    func eraseMoved(to point: CGPoint) {
        for (i, l) in layers.enumerated() {
            if l.path!.contains(point) {
                l.removeFromSuperlayer()
                layers.remove(at: i)
            }
        }
    }
    
    func eraseEnded() {
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
