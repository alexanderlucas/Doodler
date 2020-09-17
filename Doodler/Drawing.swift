//
//  Drawing.swift
//  Doodler
//
//  Created by Alex Lucas on 9/17/20.
//

import UIKit

class Drawing {
    
    var startDate: Date?
    var marks = [Mark]()
    
    func drawStarted(at point: CGPoint) -> CAShapeLayer {
        
        if marks.count == 0 {
            startDate = Date()
        }
        let mark = Mark(startingPoint: point)
        
        marks.append(mark)
        
        return mark.drawingLayer
        
    }
    
    func drawMoved(to point: CGPoint) {
        guard let mark = marks.last else {
            return
        }
        mark.addPoint(point)
    }
    
    func drawEnded() {
        
    }
    
    func eraseStarted(at point: CGPoint) {
        for mark in marks {
            if mark.path.contains(point) {
                mark.erase()
            }
        }
    }
    
    func eraseMoved(to point: CGPoint) {
        for mark in marks {
            if mark.path.contains(point) {
                mark.erase()
            }
        }
    }
    
    func eraseEnded() {
        
    }
   
}


class Mark {
    var startDate: Date
    var pathPoints: [TimeInterval: CGPoint]
    var erased: Bool
    var path: UIBezierPath
    var drawingLayer: CAShapeLayer
    
    var thumbnail: CAShapeLayer {
        let layer = drawingLayer.copy() as! CAShapeLayer
        layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        return layer
    }
    
    init(startingPoint: CGPoint) {
        startDate = Date()
        pathPoints = [TimeInterval: CGPoint]()
        pathPoints[0] = startingPoint
        erased = false
        path = UIBezierPath()
        path.move(to: startingPoint)
        
        drawingLayer = CAShapeLayer()
        drawingLayer.path = path.cgPath
        drawingLayer.fillColor = nil
        drawingLayer.strokeColor = UIColor.label.cgColor
        let thickness = Int.random(in: 0..<10)
        drawingLayer.lineWidth = CGFloat(thickness)

    }
    
    func addPoint(_ point: CGPoint)  {
        let now = Date()
        pathPoints[now.timeIntervalSince(startDate)] = point
        path.addLine(to: point)
        drawingLayer.path = path.cgPath
    }
    
    func erase() {
        self.erased = true
        drawingLayer.removeFromSuperlayer()
    }
    
    
}
